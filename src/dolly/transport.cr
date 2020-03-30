module Dolly
  record ProtocolRequest,
    id : Int32,
    method : String,
    params : Array(String),
    session_id : String?,
    page_proxy_id : String?

  record ProtocolResponse,
    id : Number,
    method : String,
    session_id : String,
    # error : { message: String, data: any, },
    params : Array(String),
    result : String,
    page_proxy_id : String

  abstract class ConnectionTransport
    abstract def send(s : ProtocolRequest)

    abstract def close

    abstract def on_message(&block : ProtocolResponse ->)

    abstract def on_close(&block : ->)
  end

  class SlowMoTransport < ConnectionTransport
    getter delay : Int32

    def initialize(@delay : Int32)

    end
  end

  class DeferWriteTransport < ConnectionTransport

  end
end
