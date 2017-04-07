Eye::Controller.class_eval do

  def set_opt_http(params = {})
    if params[:enable]
      if @http
        if params[:host] != @http.host || params[:port].to_i != @http.port
          stop_http
          start_http(params[:host], params[:port],params[:router])
        end
      else
        start_http(params[:host], params[:port],params[:router])
      end
    else
      stop_http if @http
    end
  end

  private
    def start_http(host, port,router)
      require_relative 'extended_router'
      @http = Eye::Http.new(host, port,router)
      @http.start
    end
end
