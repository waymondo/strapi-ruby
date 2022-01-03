# frozen_string_literal: true

require 'test_helper'

class Farm < Strapi::ContentType
  plural_id 'farms'
  field :name
  field :cows, content_type: 'Cow'
end

class Cow < Strapi::ContentType
  field :name
  field :farm, content_type: 'Farm'
end

class ContentTypeTest < Minitest::Test
  def setup
    stub_request(:get, 'http://localhost:1337/api/farms?populate=*')
      .to_return(body: File.read(File.join(__dir__, 'fixtures', 'farms.json')), status: 200)
    stub_request(:get, 'http://localhost:1337/api/cows/1?populate=*')
      .to_return(body: File.read(File.join(__dir__, 'fixtures', 'cow.json')), status: 200)
  end

  def test_it_can_query_farms_and_cows
    farms = Farm.all
    assert_equal farms.size, 2
    farm = farms.first
    assert_equal farm.name, 'McDonald’s'
    cow = Cow.find(1)
    assert_equal cow.id, 1
    assert_equal cow.name, 'Hershey'
    assert_equal cow.farm, farm
    assert_equal farm.cows.first, cow
  end
end
