class ApiService
    include HTTParty
  
    BASE_URI = 'http://eventregistry.org/api/v1'
  
    # Setting default headers for JSON
    headers 'Content-Type' => 'application/json'
  
    def self.fetch_articles_with_keyword(keyword, page=1)
      body = {
        action: "getArticles",
        keyword: keyword,
        articlesPage: page,
        articlesCount: 100,
        articlesSortBy: "date",
        articlesSortByAsc: false,
        articlesArticleBodyLen: -1,
        resultType: "articles",
        dataType: ["news", "pr"],
        apiKey: '64969e85-7382-4853-9155-730334994a64',
        forceMaxDataTimeWindow: 31,
        lang: "eng"
      }.to_json
  
      response = post("#{BASE_URI}/article/getArticles", body: body)
  
      if response.success?
        response.parsed_response
      else
        Rails.logger.error("API Error: #{response.body}")
        nil
      end
    end
  end