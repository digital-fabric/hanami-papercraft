# frozen_string_literal: true

require "hanami/view"
require "hanami/helpers/assets_helper"
require "papercraft"

Hanami::View::ERB::Escape = ERB::Escape

module Hanami
  class PapercraftView < Hanami::View
    include Hanami::Helpers::AssetsHelper
    class << self
      include Hanami::Helpers::AssetsHelper
    
      def _typed_url(context, source, ext)
        source = "#{source}#{ext}" if source.is_a?(String) && _append_extension?(source, ext)
        asset_url(context, source)
      end
    
      def _append_extension?(source, ext)
        source !~ QUERY_STRING_MATCHER && source !~ /#{Regexp.escape(ext)}\z/
      end
    
      def asset_url(context, source)
        return source.url if source.respond_to?(:url)
        return source if _absolute_url?(source)
      
        context.assets[source].url
      end
    
      def _absolute_url?(source)
        ABSOLUTE_URL_MATCHER.match?(source.respond_to?(:url) ? source.url : source)
      end
    
      def _nonce(context, source, nonce_option)
        if nonce_option == false
          nil
        elsif nonce_option == true || (nonce_option.nil? && !_absolute_url?(source))
          content_security_policy_nonce(context)
        else
          nonce_option
        end
      end
    
      CONTENT_SECURITY_POLICY_NONCE_REQUEST_KEY = "hanami.content_security_policy_nonce"
    
      def content_security_policy_nonce(context)
        return unless context.request
      
        context.request.env[CONTENT_SECURITY_POLICY_NONCE_REQUEST_KEY]
      end
    
      def _subresource_integrity_value(context, source, ext)
        return if _absolute_url?(source)
      
        source = "#{source}#{ext}" unless /#{Regexp.escape(ext)}\z/.match?(source)
        context.assets[source].sri
      end
    end
  
    ::Papercraft.extension(
      favicon_tag: -> {
        link href: "/assets/favicon.ico", rel: "shortcut icon", type: "image/x-icon"
      },
      stylesheet_tag: ->(context, *sources, **options) {
        options = options.reject { |k, _| k.to_sym == :href }
        nonce_option = options.delete(:nonce)
    
        sources.each do |source|
          attributes = {
            href: Hanami::PapercraftView._typed_url(context, source, Hanami::PapercraftView::STYLESHEET_EXT),
            type: Hanami::PapercraftView::STYLESHEET_MIME_TYPE,
            rel: Hanami::PapercraftView::STYLESHEET_REL,
            nonce: Hanami::PapercraftView._nonce(context, source, nonce_option)
          }
          attributes.merge!(options)
        
          if context.assets.subresource_integrity? || attributes.include?(:integrity)
            attributes[:integrity] ||= Hanami::PapercraftView._subresource_integrity_value(context, source, STYLESHEET_EXT)
            attributes[:crossorigin] ||= Hanami::PapercraftView::CROSSORIGIN_ANONYMOUS
          end
        
          link(**attributes)
        end
      },
      javascript_tag: ->(context, *sources, **options) {
        options = options.reject { |k, _| k.to_sym == :src }
        nonce_option = options.delete(:nonce)
    
        sources.each do |source|
          attributes = {
            src: Hanami::PapercraftView._typed_url(context, source, Hanami::PapercraftView::JAVASCRIPT_EXT),
            type: Hanami::PapercraftView::JAVASCRIPT_MIME_TYPE,
            nonce: Hanami::PapercraftView._nonce(context, source, nonce_option)
          }
          attributes.merge!(options)
        
          if context.assets.subresource_integrity? || attributes.include?(:integrity)
            attributes[:integrity] ||= Hanami::PapercraftView._subresource_integrity_value(context, source, JAVASCRIPT_EXT)
            attributes[:crossorigin] ||= Hanami::PapercraftView::CROSSORIGIN_ANONYMOUS
          end
        
          script(**attributes)
        end
      }
    )
    
    def call(context:, layout: nil, **props)
      layout ||= config.layout
    
      locals = exposures.(context:, **props) do |value, exposure|
        # TODO: what is decorate? and how do we support this without a rendering object
        # if exposure.decorate? && value
        #   rendering.part(exposure.name, value, as: exposure.options[:as])
        # else
          value
        # end
      end
      
      template_params = {
        context: context,
        config: config,
        **props,
        **locals
      }
    
      puts '*' * 40
      p params: template_params.keys
      puts
    
      template = load_template(config.template)
      puts template.compiled_code
      puts
    
      if layout
        layout_template = load_layout_template(layout)
        layout_template.render(**template_params, &template)
      else
        template.render(**template_params)
      end
    end
  
    def load_layout_template(name)
      root ||= config.paths.first.root
      fn = File.join(root, "layouts/#{name}.papercraft.rb")
      source = IO.read(fn)
      eval(source, binding, fn)
    end
  
    def load_template(name)
      root ||= config.paths.first.root
      fn = File.join(root, "#{name}.papercraft.rb")
      source = IO.read(fn)
      eval(source, binding, fn)
    end      
  end
end
