require 'resolv'

module DMARC
  #
  # Queries a domain for the DMARC record.
  #
  # @param [String] domain
  #   The domain to query DMARC for.
  #
  # @param [Resolv::DNS] resolver
  #   The resolver to use.
  #
  # @return [String, nil]
  #   The domain's DMARC record or `nil` if none exists.
  #
  # @api semipublic
  #
  # @since 0.3.0
  #
  def self.query(domain,resolver=Resolv::DNS.new)
    host = "_dmarc.#{domain}"

    begin
      return resolver.getresource(
        host, Resolv::DNS::Resource::IN::TXT
      ).strings.join
    rescue Resolv::ResolvError => e
      e
    rescue Encoding::CompatibilityError => e
      e
    end
  end
end
