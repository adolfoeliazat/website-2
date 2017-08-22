# frozen_string_literal: true

require "html-proofer"

raise IOError, "Directory ./build does not exist. Run `middleman build` before running tests" unless Dir.exist?("./build")

HTMLProofer.check_directory("./build",
  log_level: :debug,
  check_img_http: true,
  allow_hash_href: true,
  check_html: true, :validation => { :report_missing_names => false },
  check_favicon: false,
  check_opengraph: true,
  alt_ignore: ["https://googleads.g.doubleclick.net/pagead/viewthroughconversion/1008438803/?value=0&guid=ON&script=0"],
  http_status_ignore: [0, 999, 403, 401]).run
