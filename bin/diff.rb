#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'
require 'every_politician_scraper/scraper_data'
require 'pry'

# Standardise data
class Comparison < EveryPoliticianScraper::Comparison
  REMAP = {
    party: {
      'All India Majlis-e-Ittehadul Muslimeen' => 'All India Majlis-E-Ittehadul Muslimeen',
      'Apna Dal (Sonelal)'                     => 'Apna Dal',
      'Jammu & Kashmir National Conference'    => 'Jammu and Kashmir National Conference',
      'Lok Janshakti Party'                    => 'Lok Jan Shakti Party',
      'Marumalarchi Dravida Munnetra Kazhagam' => 'Dravida Munnetra Kazhagam',
      'Rastriya Loktantrik Party'              => 'Rashtriya Loktantrik Party',
      'YSR Congress Party'                     => 'Yuvajana Sramika Rythu Congress Party',
      'independent politician'                 => 'Independent',
      "Naga People's Front" => 'Naga Peoples Front',
      'All Jharkhand Students Union' => 'AJSU Party',
    },
    constituency: {
      'Kadapa' => 'kadapa',
      'Peddapalli' => 'Peddapalle',
      'Anantapuramu' => 'Anantapur',
      'Firozepur' => 'Ferozpur',
      'Nowgong' => 'Nawgong',
      'Cooch Behar' => 'Coochbehar',
      'Sreerampur' => 'Serampore',
      'Jhalawar' => 'Jhalawar-Baran',
      'Barrackpore' => 'Barrackpur',
    }
  }.freeze

  def name_map(val)
    MemberList::Member::Name.new(
     full:     val.split(',', 2).reverse.join(' ').tidy,
     prefixes: %w[Shri Dr. (Dr.) Prof. Smt.],
     suffixes: %w[General (Retd.)]
    ).short
  end

  def wikidata_csv_options
    { converters: [lambda { |val, field| field.header == :name ? name_map(val) : (REMAP[field.header] || {}).fetch(val, val) }] }
  end

  def external_csv_options
    { converters: [lambda { |val, field| field.header == :name ? name_map(val) : (REMAP[field.header] || {}).fetch(val, val) }] }
  end
end

diff = Comparison.new('wikidata/results/current-members.csv', 'data/official.csv').diff
puts diff.sort_by { |r| [r.first, r[1].to_s] }.reverse.map(&:to_csv)
