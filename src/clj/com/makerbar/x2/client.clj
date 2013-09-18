(ns com.makerbar.x2.client
  (:gen-class
    :name com.makerbar.x2.client.X2Client
    :methods [#^{:static true} [sendData [String "[I"] double]])
  (:require [aleph.tcp :refer [tcp-client]]
            [gloss.core :refer [defcodec header repeated]]
            [gloss.io :refer [decode encode]]
            [lamina.core :refer [enqueue wait-for-message wait-for-result]]))

(defcodec send-codec
  (header :byte
          (fn [h] (repeated :uint32))  ; body is repeated bytes, with int32 length prefix 
          (fn [b] \0)))  ; header = char \0

(defcodec receive-codec
  {:fps :float64-le})

(defn x2-client
  "X2 client"
  ([host data] (x2-client host 10000 data))
  ([host port data]
;    (println "host" host ", port" port ", data" (count data))
    (let [ch (wait-for-result (tcp-client {:host host, :port port}))]
      (enqueue ch (encode send-codec data))
      (decode receive-codec (.toByteBuffer (wait-for-message ch))))))

(defn -sendData
  [host data]
  (:fps (x2-client host (seq data))))
