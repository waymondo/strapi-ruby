# frozen_string_literal: true

module WebmockSupport
  def setup
    stub_get_requests
    stub_path_and_return_json(:put, '/cows/2', 'fixtures/403.json', 403)
    stub_path_and_return_json(:put, '/cows/3', 'fixtures/400.json', 400)
    stub_path_and_return_json(:post, '/cows', 'fixtures/cow2.json', 200)
    stub_path_and_return_json(:put, '/cows/1', 'fixtures/cow2.json', 200)
    stub_path_and_return_json(:delete, '/cows/1', 'fixtures/cow.json', 200)
  end

  private

  def stub_get_requests
    stub_path_and_return_json(:get, '/farms?populate=*', 'fixtures/farms.json', 200)
    stub_path_and_return_json(:get, '/cows?populate=*', 'fixtures/cows.json', 200)
    stub_path_and_return_json(:get, '/cows/1?populate=*', 'fixtures/cow.json', 200)
    stub_path_and_return_json(:get, '/cows/404', 'fixtures/404.json', 404)
    stub_path_and_return_json(:get, '/cows/1', 'fixtures/cow.json', 200)
    stub_path_and_return_json(:get, '/cows/2', 'fixtures/cow2.json', 200)
  end

  def stub_path_and_return_json(method, path, json, status)
    stub_request(method, "http://localhost:1337/api#{path}")
      .to_return(body: File.read(File.join(__dir__, json)), status: status)
  end
end
