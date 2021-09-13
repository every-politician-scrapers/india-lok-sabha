const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  return `SELECT ?item ?name ?group ?party
         ?district (REPLACE(?districtLabel, "Lok Sabha constituency", "", "i") AS ?constituency)
         ?state ?stateLabel ?gender ?dob ?dobPrecision
         (STRAFTER(STR(?statement), '/statement/') AS ?psid)
    WHERE
    {
      ?item p:P39 ?statement .
      ?statement ps:P39 wd:${meta.legislature.member} .
      OPTIONAL { ?statement pq:P4100 ?group }
      OPTIONAL { ?statement pq:P768 ?district }

      OPTIONAL {
        ?statement prov:wasDerivedFrom ?ref .
        ?ref pr:P854 ?source FILTER CONTAINS(STR(?source), '${meta.source.url}')
        OPTIONAL { ?ref pr:P1810 ?sourceName }
      }
      OPTIONAL { ?item rdfs:label ?wdLabel FILTER(LANG(?wdLabel) = "${meta.source.lang.code}") }
      BIND(COALESCE(?sourceName, ?wdLabel) AS ?name)

      OPTIONAL { ?item wdt:P21 ?genderItem }
      OPTIONAL { # truthiest DOB, with precison
        ?item p:P569 ?ts .
        ?ts a wikibase:BestRank .
        ?ts psv:P569 [wikibase:timeValue ?dob ; wikibase:timePrecision ?dobPrecision] .
      }
      SERVICE wikibase:label {
        bd:serviceParam wikibase:language "en".
        ?genderItem rdfs:label ?gender .
        ?district rdfs:label ?districtLabel .
        ?group rdfs:label ?party .
      }
    }
    # ${new Date().toISOString()}
    ORDER BY ?item`
}
