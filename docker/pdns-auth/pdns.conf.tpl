{{ range $key, $value := environment "PDNS_"  }}{{ $key | replace "PDNS_" "" | replace "_" "-" }}={{ $value }}
{{ end }}
