require 'json'
require "base64"

module Tzispa
  module Command

    class Project

      PROJECT_STRUCTURE = [
        'apps',
        'config',
        'config/locales',
        'data',
        'data/session',
        'logs',
        'public',
        'public/css',
        'public/css/fonts',
        'public/css/less',
        'public/img',
        'public/js',
        'repository',
        'tmp'
      ]

      PROJECT_FILE       = '.tzispaprj'
      START_FILE         = 'start.ru'
      PUMA_CONFIG_FILE   = 'puma.rb'

      DEFAULT_MOUNT_PATH = '/'

      attr_accessor :name, :apps, :created

      def initialize(name)
        @name = name
        @apps = Array.new
      end


      def generate
        if create_structure
          create_project
          create_start
          create_pumaconfig
          create_i18n 'en'
        end
      end

      def self.check?
        File.exist? "#{PROJECT_FILE}"
      end

      def self.open
        raise "This command must be runned in a Tzispa project base dir" unless self.check?
        hpj = JSON.parse String.new.tap { |ptxt|
          File.open("#{PROJECT_FILE}","r") do |f|
            while line = f.gets
              ptxt << line
            end
          end
        }
        self.new(hpj['name']).tap { |project|
          project.apps = hpj['apps']
          project.created = hpj['created']
        }
      end

      def close
        save to_h
      end

      def to_h
        Hash.new.tap { |h|
          h['name'] = name
          h['apps'] = apps
          h['created'] = created
        }
      end

      private

      def save(prj, base_dir=nil)
        base_dir = "#{base_dir}/" if base_dir
        File.open("#{base_dir}#{PROJECT_FILE}","w") do |f|
          f.write prj.to_json
        end
      end

      def create_structure
        unless File.exist? name
          Dir.mkdir "#{name}"
          PROJECT_STRUCTURE.each { |psdir|
            Dir.mkdir "#{name}/#{psdir}"
          }
        end
      end

      def create_project
        save({
          name: name,
          created: Time.new,
          apps: []
        }, name)
      end

      def create_start
        File.open("#{name}/#{START_FILE}","w") do |f|
          f.puts "require 'rack'\nrequire 'tzispa'"
        end
      end

      def create_pumaconfig
        File.open("#{name}/config/#{PUMA_CONFIG_FILE}", "w") do |f|
          f.puts PUMA_CONFIG
        end
      end

      def create_i18n(lang)
        File.open("#{name}/config/locales/#{lang}.yml", "w") do |f|
          f.puts Base64.decode64(I18N_DEFAULTS)
        end
      end

      PUMA_CONFIG = <<-PUMACONFIG
#!/usr/bin/env puma

#daemonize true
pidfile 'puma.pid'
state_path 'puma.state'

# stdout_redirect 'logs/puma.stdout', 'logs/puma.stderr'
# stdout_redirect '/u/apps/lolcat/log/stdout', '/u/apps/lolcat/log/stderr', true

# Disable request logging.
# quiet

# threads 0, 16


bind 'tcp://0.0.0.0:9292'
workers 0

on_restart do
require 'fileutils'
FileUtils.rm_rf(Dir.glob('./data/session/*'))
end

# on_worker_boot do
#   puts 'On worker boot...'
# end

# after_worker_boot do
#   puts 'On worker boot...'
# end

# on_worker_shutdown do
#   puts 'On worker boot...'
# end


tag 'your_app_tag'
worker_timeout 90
PUMACONFIG

    I18N_DEFAULTS = <<-I18NDEFAULTSBASE64
LS0tDQplbjoNCiAgZGF0ZToNCiAgICBhYmJyX2RheV9uYW1lczoNCiAgICAtIFN1bg0KICAgIC0g
TW9uDQogICAgLSBUdWUNCiAgICAtIFdlZA0KICAgIC0gVGh1DQogICAgLSBGcmkNCiAgICAtIFNh
dA0KICAgIGFiYnJfbW9udGhfbmFtZXM6DQogICAgLQ0KICAgIC0gSmFuDQogICAgLSBGZWINCiAg
ICAtIE1hcg0KICAgIC0gQXByDQogICAgLSBNYXkNCiAgICAtIEp1bg0KICAgIC0gSnVsDQogICAg
LSBBdWcNCiAgICAtIFNlcA0KICAgIC0gT2N0DQogICAgLSBOb3YNCiAgICAtIERlYw0KICAgIGRh
eV9uYW1lczoNCiAgICAtIFN1bmRheQ0KICAgIC0gTW9uZGF5DQogICAgLSBUdWVzZGF5DQogICAg
LSBXZWRuZXNkYXkNCiAgICAtIFRodXJzZGF5DQogICAgLSBGcmlkYXkNCiAgICAtIFNhdHVyZGF5
DQogICAgZm9ybWF0czoNCiAgICAgIGRlZmF1bHQ6ICIlWS0lbS0lZCINCiAgICAgIGxvbmc6ICIl
QiAlZCwgJVkiDQogICAgICBzaG9ydDogIiViICVkIg0KICAgIG1vbnRoX25hbWVzOg0KICAgIC0N
CiAgICAtIEphbnVhcnkNCiAgICAtIEZlYnJ1YXJ5DQogICAgLSBNYXJjaA0KICAgIC0gQXByaWwN
CiAgICAtIE1heQ0KICAgIC0gSnVuZQ0KICAgIC0gSnVseQ0KICAgIC0gQXVndXN0DQogICAgLSBT
ZXB0ZW1iZXINCiAgICAtIE9jdG9iZXINCiAgICAtIE5vdmVtYmVyDQogICAgLSBEZWNlbWJlcg0K
ICAgIG9yZGVyOg0KICAgIC0gOnllYXINCiAgICAtIDptb250aA0KICAgIC0gOmRheQ0KICBkYXRl
dGltZToNCiAgICBkaXN0YW5jZV9pbl93b3JkczoNCiAgICAgIGFib3V0X3hfaG91cnM6DQogICAg
ICAgIG9uZTogYWJvdXQgMSBob3VyDQogICAgICAgIG90aGVyOiBhYm91dCAle2NvdW50fSBob3Vy
cw0KICAgICAgYWJvdXRfeF9tb250aHM6DQogICAgICAgIG9uZTogYWJvdXQgMSBtb250aA0KICAg
ICAgICBvdGhlcjogYWJvdXQgJXtjb3VudH0gbW9udGhzDQogICAgICBhYm91dF94X3llYXJzOg0K
ICAgICAgICBvbmU6IGFib3V0IDEgeWVhcg0KICAgICAgICBvdGhlcjogYWJvdXQgJXtjb3VudH0g
eWVhcnMNCiAgICAgIGFsbW9zdF94X3llYXJzOg0KICAgICAgICBvbmU6IGFsbW9zdCAxIHllYXIN
CiAgICAgICAgb3RoZXI6IGFsbW9zdCAle2NvdW50fSB5ZWFycw0KICAgICAgaGFsZl9hX21pbnV0
ZTogaGFsZiBhIG1pbnV0ZQ0KICAgICAgbGVzc190aGFuX3hfbWludXRlczoNCiAgICAgICAgb25l
OiBsZXNzIHRoYW4gYSBtaW51dGUNCiAgICAgICAgb3RoZXI6IGxlc3MgdGhhbiAle2NvdW50fSBt
aW51dGVzDQogICAgICBsZXNzX3RoYW5feF9zZWNvbmRzOg0KICAgICAgICBvbmU6IGxlc3MgdGhh
biAxIHNlY29uZA0KICAgICAgICBvdGhlcjogbGVzcyB0aGFuICV7Y291bnR9IHNlY29uZHMNCiAg
ICAgIG92ZXJfeF95ZWFyczoNCiAgICAgICAgb25lOiBvdmVyIDEgeWVhcg0KICAgICAgICBvdGhl
cjogb3ZlciAle2NvdW50fSB5ZWFycw0KICAgICAgeF9kYXlzOg0KICAgICAgICBvbmU6IDEgZGF5
DQogICAgICAgIG90aGVyOiAiJXtjb3VudH0gZGF5cyINCiAgICAgIHhfbWludXRlczoNCiAgICAg
ICAgb25lOiAxIG1pbnV0ZQ0KICAgICAgICBvdGhlcjogIiV7Y291bnR9IG1pbnV0ZXMiDQogICAg
ICB4X21vbnRoczoNCiAgICAgICAgb25lOiAxIG1vbnRoDQogICAgICAgIG90aGVyOiAiJXtjb3Vu
dH0gbW9udGhzIg0KICAgICAgeF9zZWNvbmRzOg0KICAgICAgICBvbmU6IDEgc2Vjb25kDQogICAg
ICAgIG90aGVyOiAiJXtjb3VudH0gc2Vjb25kcyINCiAgICBwcm9tcHRzOg0KICAgICAgZGF5OiBE
YXkNCiAgICAgIGhvdXI6IEhvdXINCiAgICAgIG1pbnV0ZTogTWludXRlDQogICAgICBtb250aDog
TW9udGgNCiAgICAgIHNlY29uZDogU2Vjb25kcw0KICAgICAgeWVhcjogWWVhcg0KICBlcnJvcnM6
DQogICAgZm9ybWF0OiAiJXthdHRyaWJ1dGV9ICV7bWVzc2FnZX0iDQogICAgbWVzc2FnZXM6DQog
ICAgICBhY2NlcHRlZDogbXVzdCBiZSBhY2NlcHRlZA0KICAgICAgYmxhbms6IGNhbid0IGJlIGJs
YW5rDQogICAgICBwcmVzZW50OiBtdXN0IGJlIGJsYW5rDQogICAgICBjb25maXJtYXRpb246IGRv
ZXNuJ3QgbWF0Y2ggJXthdHRyaWJ1dGV9DQogICAgICBlbXB0eTogY2FuJ3QgYmUgZW1wdHkNCiAg
ICAgIGVxdWFsX3RvOiBtdXN0IGJlIGVxdWFsIHRvICV7Y291bnR9DQogICAgICBldmVuOiBtdXN0
IGJlIGV2ZW4NCiAgICAgIGV4Y2x1c2lvbjogaXMgcmVzZXJ2ZWQNCiAgICAgIGdyZWF0ZXJfdGhh
bjogbXVzdCBiZSBncmVhdGVyIHRoYW4gJXtjb3VudH0NCiAgICAgIGdyZWF0ZXJfdGhhbl9vcl9l
cXVhbF90bzogbXVzdCBiZSBncmVhdGVyIHRoYW4gb3IgZXF1YWwgdG8gJXtjb3VudH0NCiAgICAg
IGluY2x1c2lvbjogaXMgbm90IGluY2x1ZGVkIGluIHRoZSBsaXN0DQogICAgICBpbnZhbGlkOiBp
cyBpbnZhbGlkDQogICAgICBsZXNzX3RoYW46IG11c3QgYmUgbGVzcyB0aGFuICV7Y291bnR9DQog
ICAgICBsZXNzX3RoYW5fb3JfZXF1YWxfdG86IG11c3QgYmUgbGVzcyB0aGFuIG9yIGVxdWFsIHRv
ICV7Y291bnR9DQogICAgICBtb2RlbF9pbnZhbGlkOiAiVmFsaWRhdGlvbiBmYWlsZWQ6ICV7ZXJy
b3JzfSINCiAgICAgIG5vdF9hX251bWJlcjogaXMgbm90IGEgbnVtYmVyDQogICAgICBub3RfYW5f
aW50ZWdlcjogbXVzdCBiZSBhbiBpbnRlZ2VyDQogICAgICBvZGQ6IG11c3QgYmUgb2RkDQogICAg
ICByZXF1aXJlZDogbXVzdCBleGlzdA0KICAgICAgdGFrZW46IGhhcyBhbHJlYWR5IGJlZW4gdGFr
ZW4NCiAgICAgIHRvb19sb25nOg0KICAgICAgICBvbmU6IGlzIHRvbyBsb25nIChtYXhpbXVtIGlz
IDEgY2hhcmFjdGVyKQ0KICAgICAgICBvdGhlcjogaXMgdG9vIGxvbmcgKG1heGltdW0gaXMgJXtj
b3VudH0gY2hhcmFjdGVycykNCiAgICAgIHRvb19zaG9ydDoNCiAgICAgICAgb25lOiBpcyB0b28g
c2hvcnQgKG1pbmltdW0gaXMgMSBjaGFyYWN0ZXIpDQogICAgICAgIG90aGVyOiBpcyB0b28gc2hv
cnQgKG1pbmltdW0gaXMgJXtjb3VudH0gY2hhcmFjdGVycykNCiAgICAgIHdyb25nX2xlbmd0aDoN
CiAgICAgICAgb25lOiBpcyB0aGUgd3JvbmcgbGVuZ3RoIChzaG91bGQgYmUgMSBjaGFyYWN0ZXIp
DQogICAgICAgIG90aGVyOiBpcyB0aGUgd3JvbmcgbGVuZ3RoIChzaG91bGQgYmUgJXtjb3VudH0g
Y2hhcmFjdGVycykNCiAgICAgIG90aGVyX3RoYW46IG11c3QgYmUgb3RoZXIgdGhhbiAle2NvdW50
fQ0KICAgIHRlbXBsYXRlOg0KICAgICAgYm9keTogJ1RoZXJlIHdlcmUgcHJvYmxlbXMgd2l0aCB0
aGUgZm9sbG93aW5nIGZpZWxkczonDQogICAgICBoZWFkZXI6DQogICAgICAgIG9uZTogMSBlcnJv
ciBwcm9oaWJpdGVkIHRoaXMgJXttb2RlbH0gZnJvbSBiZWluZyBzYXZlZA0KICAgICAgICBvdGhl
cjogIiV7Y291bnR9IGVycm9ycyBwcm9oaWJpdGVkIHRoaXMgJXttb2RlbH0gZnJvbSBiZWluZyBz
YXZlZCINCiAgaGVscGVyczoNCiAgICBzZWxlY3Q6DQogICAgICBwcm9tcHQ6IFBsZWFzZSBzZWxl
Y3QNCiAgICBzdWJtaXQ6DQogICAgICBjcmVhdGU6IENyZWF0ZSAle21vZGVsfQ0KICAgICAgc3Vi
bWl0OiBTYXZlICV7bW9kZWx9DQogICAgICB1cGRhdGU6IFVwZGF0ZSAle21vZGVsfQ0KICBudW1i
ZXI6DQogICAgY3VycmVuY3k6DQogICAgICBmb3JtYXQ6DQogICAgICAgIGRlbGltaXRlcjogIiwi
DQogICAgICAgIGZvcm1hdDogIiV1JW4iDQogICAgICAgIHByZWNpc2lvbjogMg0KICAgICAgICBz
ZXBhcmF0b3I6ICIuIg0KICAgICAgICBzaWduaWZpY2FudDogZmFsc2UNCiAgICAgICAgc3RyaXBf
aW5zaWduaWZpY2FudF96ZXJvczogZmFsc2UNCiAgICAgICAgdW5pdDogIiQiDQogICAgZm9ybWF0
Og0KICAgICAgZGVsaW1pdGVyOiAiLCINCiAgICAgIHByZWNpc2lvbjogMw0KICAgICAgc2VwYXJh
dG9yOiAiLiINCiAgICAgIHNpZ25pZmljYW50OiBmYWxzZQ0KICAgICAgc3RyaXBfaW5zaWduaWZp
Y2FudF96ZXJvczogZmFsc2UNCiAgICBodW1hbjoNCiAgICAgIGRlY2ltYWxfdW5pdHM6DQogICAg
ICAgIGZvcm1hdDogIiVuICV1Ig0KICAgICAgICB1bml0czoNCiAgICAgICAgICBiaWxsaW9uOiBC
aWxsaW9uDQogICAgICAgICAgbWlsbGlvbjogTWlsbGlvbg0KICAgICAgICAgIHF1YWRyaWxsaW9u
OiBRdWFkcmlsbGlvbg0KICAgICAgICAgIHRob3VzYW5kOiBUaG91c2FuZA0KICAgICAgICAgIHRy
aWxsaW9uOiBUcmlsbGlvbg0KICAgICAgICAgIHVuaXQ6ICcnDQogICAgICBmb3JtYXQ6DQogICAg
ICAgIGRlbGltaXRlcjogJycNCiAgICAgICAgcHJlY2lzaW9uOiAzDQogICAgICAgIHNpZ25pZmlj
YW50OiB0cnVlDQogICAgICAgIHN0cmlwX2luc2lnbmlmaWNhbnRfemVyb3M6IHRydWUNCiAgICAg
IHN0b3JhZ2VfdW5pdHM6DQogICAgICAgIGZvcm1hdDogIiVuICV1Ig0KICAgICAgICB1bml0czoN
CiAgICAgICAgICBieXRlOg0KICAgICAgICAgICAgb25lOiBCeXRlDQogICAgICAgICAgICBvdGhl
cjogQnl0ZXMNCiAgICAgICAgICBnYjogR0INCiAgICAgICAgICBrYjogS0INCiAgICAgICAgICBt
YjogTUINCiAgICAgICAgICB0YjogVEINCiAgICBwZXJjZW50YWdlOg0KICAgICAgZm9ybWF0Og0K
ICAgICAgICBkZWxpbWl0ZXI6ICcnDQogICAgICAgIGZvcm1hdDogIiVuJSINCiAgICBwcmVjaXNp
b246DQogICAgICBmb3JtYXQ6DQogICAgICAgIGRlbGltaXRlcjogJycNCiAgdGltZToNCiAgICBh
bTogYW0NCiAgICBmb3JtYXRzOg0KICAgICAgZGVmYXVsdDogIiVhLCAlZCAlYiAlWSAlSDolTTol
UyAleiINCiAgICAgIGxvbmc6ICIlQiAlZCwgJVkgJUg6JU0iDQogICAgICBzaG9ydDogIiVkICVi
ICVIOiVNIg0KICAgIHBtOiBwbQ0K
I18NDEFAULTSBASE64


    end


  end
end
