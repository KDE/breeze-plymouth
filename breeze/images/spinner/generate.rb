360.times do |i|
    next unless (i % 10 == 0) # Every 10 degrees we want a frame to render
    system("convert ../spinner.png -distort SRT #{i} spinner#{i}.png")
end
