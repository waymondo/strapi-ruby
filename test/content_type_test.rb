# frozen_string_literal: true

require 'test_helper'
require 'webmock_support'

class Farm < Strapi::ContentType
  plural_id 'farms'
  field :name
  field :cows, content_type: 'Cow'
end

class Cow < Strapi::ContentType
  plural_id 'cows'
  field :name
  field :is_sick
  field :last_known_disease
  field :age
  field :weight_in_kilogram
  field :photo, content_type: Strapi::Media
  field :farm, content_type: 'Farm'
end

class FarmWorker < Strapi::ContentType
end

class ContentTypeTest < Minitest::Test
  include WebmockSupport

  def test_it_can_query_farms_and_cows
    farms = Farm.all(populate: '*')
    assert_equal farms.size, 2
    farm = farms.first
    assert_equal farm.name, 'McDonald’s'
    cow = Cow.find(1, populate: '*')
    assert_equal cow.id, 1
    assert_equal cow.name, 'Hershey'
    assert_equal cow.farm, farm
    assert_equal farm.cows.first, cow
  end

  def test_it_validates_query_params
    error = assert_raises(Strapi::Error) { Farm.all(foo: 'bar') }
    assert_equal error.message, 'Unallowed query params - foo'
  end

  def test_it_throws_a_error_when_it_cannot_find_a_cow
    error = assert_raises(Strapi::Error) { Cow.find(404) }
    assert_equal error.message, 'Not Found'
  end

  def test_it_infers_plural_id
    assert_equal FarmWorker.send(:_plural_id), 'farm-workers'
  end

  def test_it_throws_an_error_when_it_cannot_update_a_cow
    cow = Cow.new
    cow.name = 'Milky'
    cow.instance_variable_set('@id', 2)
    error = assert_raises(Strapi::Error) { cow.save }
    assert_equal error.message, 'Forbidden'
  end

  def test_it_throws_validation_error_for_missing_name
    cow = Cow.new(pattern: 'Jersey', name: nil)
    cow.instance_variable_set('@id', 3)
    error = assert_raises(Strapi::Error) { cow.save }
    assert_equal error.message, 'name must be at least 1 characters'
  end

  def test_it_can_create_a_cow
    cow = Cow.new(name: 'Milky')
    assert_nil cow.id
    assert_equal cow.name, 'Milky'
    cow.save
    refute_nil cow.id
  end

  def test_it_can_create_a_cow_with_create
    cow = Cow.create(name: 'Milky')
    refute_nil cow.id
    assert_equal cow.name, 'Milky'
  end

  def test_it_can_update_a_cow
    cow = Cow.find(1, populate: '*')
    refute_nil cow.id
    refute_nil cow.farm.name
    assert_equal cow.name, 'Hershey'
    cow.name = 'Milky'
    assert_equal cow.save, cow
    assert_equal cow.name, 'Milky'
    refute_nil cow.farm.name
  end

  def test_it_can_delete_a_cow
    cow = Cow.find(1)
    cow.delete
    assert_equal cow.deleted, true
  end

  def test_it_can_parse_strapi_media
    cow = Cow.find(1)
    assert_equal cow.photo.url, 'http://localhost:1337/uploads/cow_8fdf0d4e0a.png'
    cow = Cow.find(2)
    assert_equal cow.photo.url, 'https://res.cloudinary.com/uploads/cow_8fdf0d4e0a.png'
  end

  def test_it_return_field_type_correctly
    cow = Cow.find(1)
    assert_equal cow.name, 'Hershey'
    assert_equal cow.is_sick, false
    assert_nil cow.last_known_disease
    assert_equal cow.age, 4
    assert_equal cow.weight_in_kilogram, 456.7
  end

  def test_it_return_datetime_field_type_correctly
    cow = Cow.find(1)

    assert cow.created_at.is_a?(DateTime)
    assert cow.updated_at.is_a?(DateTime)
    assert cow.published_at.is_a?(DateTime)
  end

  def test_it_ignores_datetime_private_attributes_and_prints_message
    assert_output(/`.created_at` is a private attribute and already defined/) do
      Cow.send(:field, :created_at)

      cow = Cow.find(1)
      assert cow.created_at.is_a?(DateTime)
    end
  end
end
