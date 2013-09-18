(defproject com.makerbar/x2 "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :source-paths ["src/clj"]
  :repositories {"project" "file:repo"}
  :dependencies [[aleph "0.3.0"]
                 [org.clojure/clojure "1.5.1"]]
  :aot [com.makerbar.x2.client]
)
