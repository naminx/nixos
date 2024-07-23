#!/usr/bin/env fish

tryeven -triml 403 -trimr 4241
for file_b in _???b.*
    mv {$file_b} two/(string replace "_" "" {$file_b})
end

for right03 in (string split -r -m1 . -f1 (ls ??{2,4,6,8,0}.jpg))
    set right (string trim -l -c0 {$right03})
    set left03 (string pad -c0 -w3 (math {$right}+1))

#   doone -triml 18 -trimr 1524 {$right}
#   for j in _{$right03}b.*
#       mv {$j} (string replace -r "_([0-9][0-9][0-9])b" '$1a' {$j})
#   end
    cp {$right03}.jpg {$right03}a.jpg
    xtrim 12- {$right03}a.jpg


#   doone -triml 18 -trimr 1524 {$right}
#   for j in _{$right03}b.*
#       mv {$j} (string replace -r "_([0-9][0-9][0-9])b" '$1c' {$j})
#   end
    cp {$left03}.jpg {$right03}c.jpg
    xtrim -11 1- {$right03}c.jpg

    mv {$right03}.jpg {$left03}.jpg stock
end
