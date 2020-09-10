#!/usr/bin/env ruby
#--
# SPDX-FileCopyrightText: 2016 Harald Sitter <sitter@kde.org>
#
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
#--

Dir.chdir("#{__dir__}/../breeze/images/spinner/")

360.times do |i|
    next unless (i % 10 == 0) # Every 10 degrees we want a frame to render
    system("convert ../spinner.png -distort SRT #{i} spinner#{i}.png")
end
