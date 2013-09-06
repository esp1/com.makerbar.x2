(ns com.makerbar.x2.client
  (:gen-class
    :name com.makerbar.x2.X2Client
    :methods [#^{:static true} [sendData [java.util.List] void]])
  (:require [aleph.tcp :refer [tcp-client]]
            [gloss.core :refer [defcodec header repeated]]
            [lamina.core :refer [enqueue wait-for-result]]))

(defcodec x2-codec
  (header :byte
          (fn [h] (repeated :byte))  ; body is repeated bytes, with int32 length prefix 
          (fn [b] \0)))  ; header = char \0

(defn x2-client
  "X2 client"
  ([panel-data] (x2-client "localhost" 10000 panel-data))
  ([host panel-data] (x2-client host 10000 panel-data))
  ([host port panel-data]
    (let [ch (wait-for-result
               (tcp-client {:host host
                            :port port
                            :frame x2-codec}))]
      (enqueue ch panel-data))))

(defn -sendData [panel-data] (x2-client panel-data))
