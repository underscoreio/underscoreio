require "rake/testtask"

js_sources = Rake::FileList.new("src/_browserify/**/*")

css_sources = Rake::FileList.new("src/_less/**/*")

def browserify_command_line(source, target)
  """
  node_modules/browserify/bin/cmd.js
  --debug
  --extension .js
  --extension .coffee
  --transform coffeeify
  --global-transform uglifyify
  #{source} > #{target}
  """.strip.split(/[\r\n]+ +/).join(" ")
end

def lesscss_command_line(source, target)
  """
  node_modules/less/bin/lessc
  --include-path=src/_less:node_modules
  #{source} |

  node_modules/postcss-cli/bin/postcss
  --map
  --use autoprefixer
  --autoprefixer.browsers '> 5%'
  --use cssnano
  --no-cssnano.discardUnused
  --output #{target}
  """.strip.split(/[\r\n]+ +/).join(" ")
end

def deploy_command_line(bucket, cloudfront)
  "S3_BUCKET=#{bucket} CLOUDFRONT_DISTRIBUTION_ID=#{cloudfront} s3_website push"
end

task :'node-deps' do
  sh "yarn"
end

file "screen.css" => [ :'node-deps' ] + css_sources do
  sh lesscss_command_line("src/_less/screen.less", "src/_assets/css/screen.css")
end

file "print.css" => [ :'node-deps' ] + css_sources do
  sh "yarn"
  sh lesscss_command_line("src/_less/print.less", "src/_assets/css/print.css")
end

file "site.js" => [ :'node-deps' ] + js_sources do
  sh "yarn"
  sh browserify_command_line("src/_browserify/site.coffee", "src/_assets/js/site.js")
end

task :'ruby-deps' do
  sh "bundle install"
end

task :build => [ "site.js", "screen.css", "print.css", :'ruby-deps' ] do
  sh "jekyll build --trace --incremental"
end

task :serve => [ "site.js", "screen.css", "print.css", :'ruby-deps' ] do
  sh "jekyll serve --trace --incremental"
end

Rake::TestTask.new do |t|
  # No tests at the moment
  t.test_files = FileList["tests/**/*.rb"]
end

task :test => :build

task :'deploy-production' => :build do |t, args|
  if `git rev-parse --abbrev-ref HEAD` == "master\n"
    sh deploy_command_line("underscore.io", "EZ3DZ8A1CPWTK")
  else
    fail "deploy-production can only be run from master"
  end
end

task :'deploy-beta' => :build do |t, args|
  sh deploy_command_line("beta.underscore.io", "")
end

task default: :build
