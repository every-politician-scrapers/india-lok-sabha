#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'
require 'every_politician_scraper/scraper_data'
require 'pry'

# Standardise data
class Comparison < EveryPoliticianScraper::Comparison
  REMAP = {
    party:        {
      'All India Majlis-e-Ittehadul Muslimeen' => 'All India Majlis-E-Ittehadul Muslimeen',
      'All Jharkhand Students Union'           => 'AJSU Party',
      'Apna Dal (Sonelal)'                     => 'Apna Dal',
      'Apna Dal (Soneylal)'                    => 'Apna Dal',
      'Jammu & Kashmir National Conference'    => 'Jammu and Kashmir National Conference',
      'Lok Janshakti Party'                    => 'Lok Jan Shakti Party',
      'Marumalarchi Dravida Munnetra Kazhagam' => 'Dravida Munnetra Kazhagam',
      "Naga People's Front"                    => 'Naga Peoples Front',
      'Rastriya Loktantrik Party'              => 'Rashtriya Loktantrik Party',
      'YSR Congress Party'                     => 'Yuvajana Sramika Rythu Congress Party',
      'independent politician'                 => 'Independent',
    },
    constituency: {
      'Anakapalli'                => 'Anakapalle',
      'Anantapuramu'              => 'Anantapur',
      'Barrackpore'               => 'Barrackpur',
      'Belagavi'                  => 'Belgaum',
      'Bhuvanagiri'               => 'Bhongir',
      'Chamarajanagar'            => 'Chamrajanagar',
      'Chikballapur'              => 'Chikkballapur',
      'Chikodi'                   => 'Chikkodi',
      'Cooch Behar'               => 'Coochbehar',
      'Davangere'                 => 'Davanagere',
      'Firozepur'                 => 'Ferozpur',
      'Haridwar'                  => 'Hardwar',
      'Janjgir'                   => 'Janjgir-Champa',
      'Jhalawar'                  => 'Jhalawar-Baran',
      'Kadapa'                    => 'kadapa',
      'Kanyakumari'               => 'Kanniyakumari',
      'Mandsaur'                  => 'Mandsour',
      'Mavelikara'                => 'Mavelikkara',
      'Mayiladuturai'             => 'Mayiladuthurai',
      'Mumbai North Central'      => 'Mumbai-North-Central',
      'Mumbai North East'         => 'Mumbai-North-East',
      'Mumbai North West'         => 'Mumbai-North-West',
      'Mumbai North'              => 'Mumbai-North',
      'Mumbai South Central'      => 'Mumbai South-Central',
      'Mumbai South'              => 'Mumbai-South',
      'Nowgong'                   => 'Nawgong',
      'Peddapalli'                => 'Peddapalle',
      'Sreerampur'                => 'Serampore',
      'Thiruvallur'               => 'Tiruvallur',
      'Thoothukudi in Tamil Nadu' => 'Thoothukkudi',
    },
  }.freeze

  CSV::Converters[:remap] = lambda { |val, field|
    return (REMAP[field.header] || {}).fetch(val, val) unless field.header == :name

    MemberList::Member::Name.new(
      full:     val.split(',', 2).reverse.join(' ').tidy,
      prefixes: %w[Shri Dr. (Dr.) Prof. Smt.],
      suffixes: %w[General (Retd.)]
    ).short
  }

  def wikidata_csv_options
    { converters: [:remap] }
  end

  def external_csv_options
    { converters: [:remap] }
  end
end

diff = Comparison.new('wikidata/results/current-members.csv', 'data/official.csv').diff
puts diff.sort_by { |r| [r.first.to_s, r[1].to_s] }.reverse.map(&:to_csv)
