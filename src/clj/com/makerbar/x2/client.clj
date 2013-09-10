(ns com.makerbar.x2.client
  (:gen-class
    :name com.makerbar.x2.X2Client
    :methods [#^{:static true} [sendData [processing.core.PImage] long]])
  (:require [aleph.tcp :refer [tcp-client]]
            [gloss.core :refer [defcodec header repeated]]
            [gloss.io :refer [decode encode]]
            [lamina.core :refer [enqueue wait-for-message wait-for-result]]))

(defcodec send-codec
  (header :byte
          (fn [h] (repeated :uint32))  ; body is repeated bytes, with int32 length prefix 
          (fn [b] \0)))  ; header = char \0

(defcodec receive-codec
  :uint64-le)

(defn x2-client
  "X2 client"
  ([data] (x2-client "localhost" 10000 data))
  ([host data] (x2-client host 10000 data))
  ([host port data]
    (let [ch (wait-for-result (tcp-client {:host host, :port port}))]
      (enqueue ch (encode send-codec data))
      (decode receive-codec (.toByteBuffer (wait-for-message ch))))))

(defn -sendData
  [pimage]
  (let [data (seq (.pixels pimage))]
    (x2-client data)))
