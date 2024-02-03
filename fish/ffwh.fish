for i in {$argv}
    echo {$i}: (magick identify -ping -format %wx%h {$i})
end
