#
# Copyright (c) 2017 joshua stein <jcs@jcs.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

Encoding.default_internal = Encoding.default_external = Encoding::UTF_8

APP_ROOT = File.realpath(File.dirname(__FILE__) + "/../")

RUBYWARDEN_ENV ||= (ENV["RUBYWARDEN_ENV"] || ENV["RACK_ENV"] || "development")

require "sqlite3"
require "active_record"

require "sinatra/base"
require "sinatra/namespace"
require "cgi"

require "#{APP_ROOT}/lib/bitwarden.rb"
require "#{APP_ROOT}/lib/helper.rb"

require "#{APP_ROOT}/lib/db.rb"
require "#{APP_ROOT}/lib/dbmodel.rb"
require "#{APP_ROOT}/lib/user.rb"
require "#{APP_ROOT}/lib/device.rb"
require "#{APP_ROOT}/lib/cipher.rb"
require "#{APP_ROOT}/lib/folder.rb"
require "#{APP_ROOT}/lib/attachment.rb"

BASE_URL = (ENV["RUBYWARDEN_BASE_URL"] || "/api")
IDENTITY_BASE_URL = (ENV["RUBYWARDEN_IDENTITY_BASE_URL"] || "/identity")
ICONS_URL = (ENV["RUBYWARDEN_ICONS_URL"] || "/icons")
ATTACHMENTS_URL = (ENV["RUBYWARDEN_ATTACHMENTS_URL"] || "/attachments")

conf_file = File.open(ENV["RUBYWARDEN_CONF"])

for conf in conf_file.readlines.map(&:chomp) do
  if conf.include? "ALLOW_SIGNUPS"
    num = conf.split('=')[1].to_i
    if num.to_s == conf.split('=')[1]
      ALLOW_SIGNUPS = num
    else
      ALLOW_SIGNUPS = false
    end
  end
end  

# whether to allow new users
#if !defined?(ALLOW_SIGNUPS)
#  ALLOW_SIGNUPS = (ENV["RUBYWARDEN_ALLOW_SIGNUPS"] || ENV["ALLOW_SIGNUPS"] || false)
#end

# create/load JWT signing keys
Bitwarden::Token.load_keys

# connect to db
Db.connect(environment: RUBYWARDEN_ENV)
