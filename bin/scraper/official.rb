#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'open-uri/cached'
require 'pry'

class Legislature
  # details for an individual member
  class Member < Scraped::HTML
    field :seatnum do
      tds[0].text.to_i
    end

    field :id do
      tds[1].css('a/@href').first.text[/mpsno=(\d+)/, 1]
    end

    field :name do
      tds[1].text.tidy
    end

    field :party do
      tds[2].text.tidy
    end

    field :constituency do
      tds[3].text.tidy
    end

    private

    def tds
      noko.css('td')
    end
  end

  # The page listing all the members
  class Members < Scraped::HTML
    field :members do
      member_container.map { |member| fragment(member => Member) }.map(&:to_h).uniq
    end

    private

    def member_container
      noko.css('.member_list_table').xpath('.//tr[td]').drop(1)
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file, klass: Legislature::Members).csv
