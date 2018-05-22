require "httparty"

module WhitelistCloudfrontProxies
  module Rails
    class Railtie < ::Rails::Railtie

      module CheckTrustedProxies
        def trusted_proxy?(ip)
          ::Rails.application.config.whitelist_cloudfront_proxies.ips.any?{ |proxy| proxy === ip } || super
        end
      end

      Rack::Request::Helpers.prepend CheckTrustedProxies

      module RemoteIpProxies
        def proxies
          super + ::Rails.application.config.whitelist_cloudfront_proxies.ips
        end
      end

      ActionDispatch::RemoteIp.prepend RemoteIpProxies

      class Importer
        include HTTParty

        base_uri "https://ip-ranges.amazonaws.com"
        follow_redirects true
        default_options.update(verify: true)

        class ResponseError < HTTParty::ResponseError; end

        class << self
          def fetch
            resp = get "/ip-ranges.json", timeout: ::Rails.application.config.whitelist_cloudfront_proxies.timeout

            if resp.success?
              json = ActiveSupport::JSON.decode resp.body

              trusted_ipv4_proxies = json["prefixes"].select do |details|
                                       details["service"] == 'CLOUDFRONT'
                                     end.map do |details|
                                       IPAddr.new(details["ip_prefix"])
                                     end

              trusted_ipv6_proxies = json["ipv6_prefixes"].select do |details|
                                       details["service"] == 'CLOUDFRONT'
                                     end.map do |details|
                                       IPAddr.new(details["ipv6_prefix"])
                                     end

              trusted_ipv4_proxies + trusted_ipv6_proxies
            else
              raise ResponseError.new(resp.response)
            end
          end

          def fetch_with_cache
            ::Rails.cache.fetch("whitelisted-cloudfront-proxies",
                                expires_in: ::Rails.application.config.whitelist_cloudfront_proxies.expires_in) do
              self.fetch
            end
          end
        end
      end

      CLOUDFRONT_DEFAULTS = {
        expires_in: 12.hours,
        timeout: 5.seconds,
        ips: Array.new
      }

      config.before_configuration do |app|
        app.config.whitelist_cloudfront_proxies = ActiveSupport::OrderedOptions.new
        app.config.whitelist_cloudfront_proxies.reverse_merge! CLOUDFRONT_DEFAULTS
      end

      config.after_initialize do |app|
        begin
          ::Rails.application.config.whitelist_cloudfront_proxies.ips += Importer.fetch_with_cache
        rescue Importer::ResponseError => e
          ::Rails.logger.error "WhitelistCloudfrontProxies::Rails: Couldn't import from Cloudfront: #{e.response}"
        rescue => e
          ::Rails.logger.error "WhitelistCloudfrontProxies::Rails: Got exception: #{e}"
        end
      end

    end
  end
end
