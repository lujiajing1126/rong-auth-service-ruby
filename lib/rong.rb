class RongAuthService
  def initialize(data={})
    @format = 'json'
    @url = 'https://api.cn.rong.io'
    @appKey = 'df98wer'
    @appSecret = 'de9ur4ijof9u8r'
    @userId = ''
    @name = ''
    @portraitUri = ''
    setOptions(data)
  end
  def request
    url = @url + '/user/getToken.' + @format
    params = {:userId => @userId,:format => @format,:name => @name, :portraitUri => @portraitUri}
    httpHeader = {:appKey => @appKey, :appSecret => @appSecret}
    curl url,params,httpHeader
  end
  class << self
    def formatResponseData(arr,format='json')
      if format == 'json'
        JSON.parser(arr)
      else
        self.arrToXml(arr,true)
      end
    end
    def arrToXml(data,flag=true,key='',type=0)
      xml = ''
      xml += '<result>\n' if flag == true
      data.each do |k,v|
          if v.is_a?(Hash)
              xml += (k.is_a?(Numeric) ? "<item>" : "<#{k}>" ) + "\n" + self.arrToXml(v,false,k,type) + (k.is_a?(Numeric) ? '</item>' : "</#{k}>")+"\n"
          else
              xml += "<#{k}>" + (v.is_a?(Numeric)?v:"<![CDATA[#{v}]]>") + "</#{k}>\n"
          end
      end
      xml += '</result>' if flag == true
      return xml
    end
  end
  private
  def setOptions(data)
    unless data.blank?
      self.instance_variables.each do |k|
        instance_variable_set(k,data[k]) if data[k] != nil
      end
    end
  end
  def curl(url,params,httpHeaders,method='post')
    conn = Faraday.new(:url => url) do |faraday|
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end
    # GET
    if method.upcase == 'GET'
      response = conn.get do |req|
        req.url url
        req.params = params
      end
    else
      # POST
      response = conn.post url,params,httpHeaders
    end
    {:httpInfo => 'httpInfo',:ret => response}
  end
end