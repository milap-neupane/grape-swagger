require 'spec_helper'

describe 'a simple mounted api' do
  before :all do
    class CustomType; end

    class SimpleMountedApi < Grape::API
      desc 'Document root'
      get do
      end

      desc 'This gets something.',
        notes: '_test_'

      get '/simple' do
        { bla: 'something' }
      end

      desc 'This gets something for URL using - separator.',
        notes: '_test_'

      get '/simple-test' do
        { bla: 'something' }
      end

      desc 'this gets something else',
        headers: {
          'XAuthToken' => { description: 'A required header.', required: true },
          'XOtherHeader' => { description: 'An optional header.', required: false }
        },
        http_codes: [
          { code: 403, message: 'invalid pony' },
          { code: 405, message: 'no ponies left!' }
        ]

      get '/simple_with_headers' do
        { bla: 'something_else' }
      end

      desc 'this takes an array of parameters',
        params: {
          'items[]' => { description: 'array of items', is_array: true }
        }

      post '/items' do
        {}
      end

      desc 'this uses a custom parameter',
        params: {
          'custom' => { type: CustomType, description: 'array of items', is_array: true }
        }

      get '/custom' do
        {}
      end
    end

    class SimpleApi < Grape::API
      mount SimpleMountedApi
      add_swagger_documentation
    end
  end

  def app
    SimpleApi
  end

  describe "retrieves swagger-documentation on /swagger_doc" do
    subject do
      get '/swagger_doc.json'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject).to eq({
        "info"=>{"title"=>"API title", "version"=>"v1"},
        "swagger"=>"2.0",
        "produces"=>["application/xml", "application/json", "application/octet-stream", "text/plain"],
        "host"=>"example.org",
        "tags" => [{"name"=>"simple", "description"=>"Operations about simples"}, {"name"=>"simple-test", "description"=>"Operations about simple-tests"}, {"name"=>"simple_with_headers", "description"=>"Operations about simple_with_headers"}, {"name"=>"items", "description"=>"Operations about items"}, {"name"=>"custom", "description"=>"Operations about customs"}],
        "paths"=>{
          "/simple"=>{
            "get"=>{
              "description"=>"This gets something.",
              "produces"=>["application/json"],
              "tags"=>["simple"],
              "operationId"=>"getSimple",
              "responses"=>{"200"=>{"description"=>"This gets something."}}}},
          "/simple-test"=>{
            "get"=>{
              "description"=>"This gets something for URL using - separator.",
              "produces"=>["application/json"],
              "tags"=>["simple-test"],
              "operationId"=>"getSimpleTest",
              "responses"=>{"200"=>{"description"=>"This gets something for URL using - separator."}}}},
          "/simple_with_headers"=>{
            "get"=>{
              "description"=>"this gets something else",
              "produces"=>["application/json"],
              "parameters"=>[
                {"in"=>"header", "name"=>"XAuthToken", "description"=>"A required header.", "type"=>"string", "required"=>true},
                {"in"=>"header", "name"=>"XOtherHeader", "description"=>"An optional header.", "type"=>"string", "required"=>false}],
              "tags"=>["simple_with_headers"],
              "operationId"=>"getSimpleWithHeaders",
              "responses"=>{
                "200"=>{"description"=>"this gets something else"},
                "403"=>{"description"=>"invalid pony"},
                "405"=>{"description"=>"no ponies left!"}}
          }},
          "/items"=>{
            "post"=>{
              "description"=>"this takes an array of parameters",
              "produces"=>["application/json"],
              "consumes"=>["application/json"],
              "parameters"=>[{"in"=>"formData", "name"=>"items[]", "description"=>"array of items", "required"=>false, "type"=>"array", "items"=>{"type"=>"string"}}],
              "tags"=>["items"],
              "operationId"=>"postItems",
              "responses"=>{"201"=>{"description"=>"this takes an array of parameters", "schema"=>{"$ref"=>"#/definitions/Item"}}}
          }},
          "/custom"=>{
            "get"=>{
              "description"=>"this uses a custom parameter",
              "produces"=>["application/json"],
              "parameters"=>[{"in"=>"formData", "name"=>"custom", "description"=>"array of items", "required"=>false, "type"=>"array", "items"=>{"type"=>"CustomType"}}],
              "tags"=>["custom"],
              "operationId"=>"getCustom",
              "responses"=>{"200"=>{"description"=>"this uses a custom parameter", "schema"=>{"$ref"=>"#/definitions/Custom"}}}}
      }},
      "definitions"=>{
        "Item"=>{
          "type"=>"object",
          "properties"=>{"items[]"=>{"type"=>"string"}},
          "description"=>"this takes an array of parameters"
        },
        "Custom"=>{
          "type"=>"object",
          "properties"=>{"custom"=>{"type"=>"CustomType"}},
          "description"=>"this uses a custom parameter"
        }}})
    end
  end

  describe 'retrieves the documentation for mounted-api' do
    subject do
      get '/swagger_doc/simple.json'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject).to eq({
        "info"=>{"title"=>"API title", "version"=>"v1"},
        "swagger"=>"2.0",
        "produces"=>["application/xml", "application/json", "application/octet-stream", "text/plain"],
        "host"=>"example.org",
        "tags" => [{"name"=>"simple", "description"=>"Operations about simples"}, {"name"=>"simple-test", "description"=>"Operations about simple-tests"}, {"name"=>"simple_with_headers", "description"=>"Operations about simple_with_headers"}, {"name"=>"items", "description"=>"Operations about items"}, {"name"=>"custom", "description"=>"Operations about customs"}],
        "paths"=>{
          "/simple"=>{
            "get"=>{
              "description"=>"This gets something.",
              "produces"=>["application/json"],
              "tags"=>["simple"],
              "operationId"=>"getSimple",
              "responses"=>{"200"=>{"description"=>"This gets something."}}}}
        }})
    end
  end

  describe 'retrieves the documentation for mounted-api that' do
    describe "contains '-' in URL" do
      subject do
        get '/swagger_doc/simple-test.json'
        JSON.parse(last_response.body)
      end

      specify do
        expect(subject).to eq({
          "info"=>{"title"=>"API title", "version"=>"v1"},
          "swagger"=>"2.0",
          "produces"=>["application/xml", "application/json", "application/octet-stream", "text/plain"],
          "host"=>"example.org",
          "tags" => [{"name"=>"simple", "description"=>"Operations about simples"}, {"name"=>"simple-test", "description"=>"Operations about simple-tests"}, {"name"=>"simple_with_headers", "description"=>"Operations about simple_with_headers"}, {"name"=>"items", "description"=>"Operations about items"}, {"name"=>"custom", "description"=>"Operations about customs"}],
          "paths"=>{
            "/simple-test"=>{
              "get"=>{
                "description"=>"This gets something for URL using - separator.",
                "produces"=>["application/json"],
                "tags"=>["simple-test"],
                "operationId"=>"getSimpleTest",
                "responses"=>{"200"=>{"description"=>"This gets something for URL using - separator."}}}}
          }})
      end
    end

    describe 'includes headers' do
      subject do
        get '/swagger_doc/simple_with_headers.json'
        JSON.parse(last_response.body)
      end

      specify do
        expect(subject['paths']).to eq({
          "/simple_with_headers"=>{
            "get"=>{
              "description"=>"this gets something else",
              "produces"=>["application/json"],
              "parameters"=>[
                {"in"=>"header", "name"=>"XAuthToken", "description"=>"A required header.", "type"=>"string", "required"=>true},
                {"in"=>"header", "name"=>"XOtherHeader", "description"=>"An optional header.", "type"=>"string", "required"=>false}],
              "tags"=>["simple_with_headers"],
              "operationId"=>"getSimpleWithHeaders",
              "responses"=>{
                "200"=>{"description"=>"this gets something else"},
                "403"=>{"description"=>"invalid pony"},
                "405"=>{"description"=>"no ponies left!"}}}
          }})
      end
    end

    describe 'supports array params' do
      subject do
        get '/swagger_doc/items.json'
        JSON.parse(last_response.body)
      end

      specify do
        expect(subject['paths']).to eq({
          "/items"=>{
            "post"=>{
              "description"=>"this takes an array of parameters",
              "produces"=>["application/json"],
              "consumes"=>["application/json"],
              "parameters"=>[{"in"=>"formData", "name"=>"items[]", "description"=>"array of items", "required"=>false, "type"=>"array", "items"=>{"type"=>"string"}}],
              "tags"=>["items"],
              "operationId"=>"postItems",
              "responses"=>{"201"=>{"description"=>"this takes an array of parameters", "schema"=>{"$ref"=>"#/definitions/Item"}}}}
          }})
      end
    end

    describe 'supports custom params types' do
      subject do
        get '/swagger_doc/custom.json'
        JSON.parse(last_response.body)
      end

      specify do
        expect(subject['paths']).to eq({
          "/custom"=>{
            "get"=>{
              "description"=>"this uses a custom parameter",
              "produces"=>["application/json"],
              "parameters"=>[{"in"=>"formData", "name"=>"custom", "description"=>"array of items", "required"=>false, "type"=>"array", "items"=>{"type"=>"CustomType"}}],
              "tags"=>["custom"],
              "operationId"=>"getCustom",
              "responses"=>{"200"=>{"description"=>"this uses a custom parameter", "schema"=>{"$ref"=>"#/definitions/Custom"}}}}
          }})
      end
    end
  end
end
