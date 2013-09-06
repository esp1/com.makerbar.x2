(defproject x2 "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :source-paths ["src/clj"]
  :java-source-paths ["src/java"
                      "src/xtend-gen"]
  :javac-options ["-target" "1.7"
                  "-source" "1.7"]
  :repositories {"project" "file:repo"}
  :dependencies [[aleph "0.3.0-rc2"]
                 [org.clojure/clojure "1.5.1"]
                 [org.eclipse.xtend/org.eclipse.xtend.lib "2.4.3"]
                 [org.processing/core "2.0.2"]
                 [org.processing/gstreamer-java "2.0.2"]
                 [org.processing/jna "2.0.2"]
                 [org.processing/RXTXcomm "2.0.2"]
                 [org.processing/serial-native-deps "2.0.2"]
                 [org.processing/serial "2.0.2"]
                 [org.processing/video "2.0.2"]
                 [org.processing/video-native-deps "2.0.2"]]
  :jvm-opts ["-Djava.library.path=native/macosx/x86_64"
             "-Dgstreamer.library.path=native/macosx/x86_64"
             "-Dgstreamer.plugin.path=native/macosx/x86_64/plugins"]
  :native-path "native"
  :aot [com.makerbar.x2.client]
)
