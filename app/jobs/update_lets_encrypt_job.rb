class UpdateLetsEncryptJob < Resque::Job
  @queue = :high

  def self.perform
    cert_generator = LetsencryptPlugin::CertGenerator.new(LetsencryptPlugin.config.to_h)
    cert_generator.generate_certificate
  end
end