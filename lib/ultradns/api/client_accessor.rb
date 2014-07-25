
class Ultradns::Api::ClientAccessor

  def initialize(client)
    @client = client
    if client.kind_of?(Ultradns::Api::ClientAccessor)
      @client = client.client
    end
  end

  protected
  #########

  def client
    @client
  end

  def request_options(params = {})
    @client.send :request_options, params
  end


end
