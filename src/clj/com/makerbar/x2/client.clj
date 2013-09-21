(ns com.makerbar.x2.client
  (:gen-class
    :name com.makerbar.x2.client.X2Client
    :methods [#^{:static true} [sendData [String "[I"] java.util.List]
              #^{:static true} [getStats [String] java.util.List]
              #^{:static true} [setXOffset [String int] int]
              #^{:static true} [setBrightness [String float] float]
              #^{:static true} [setContrast [String float] float]])
  (:require [aleph.tcp :refer [tcp-client]]
            [gloss.core :refer [defcodec header repeated]]
            [gloss.io :refer [decode encode]]
            [lamina.core :refer [enqueue wait-for-message wait-for-result]]))

(defn get-ch
  [host]
  (wait-for-result (tcp-client {:host host, :port 10000})))

(defcodec send-codec
  (header :byte
          (fn [h] (repeated :uint32))  ; body is repeated bytes, with int32 length prefix 
          (fn [b] \0)))  ; header = char \0

(defcodec command-codec
  :byte)

(defcodec return-stats-codec
  {:rps :float64-le
   :fps :uint32-le})

(defcodec return-int-codec
  {:value :uint32-le})

(defcodec return-float-codec
  {:value :float32-le})

(defn send-data
  [host data]
;    (println "host" host ", port" port ", data" (count data))
  (let [ch (get-ch host)]
    (enqueue ch (encode send-codec data))
    (decode return-stats-codec (.toByteBuffer (wait-for-message ch)))))

(defn get-stats
  [host]
  (let [ch (get-ch host)]
    (enqueue ch (encode command-codec \?))
    (decode return-stats-codec (.toByteBuffer (wait-for-message ch)))))

;;; Java static methods

(defn -sendData
  [host data]
  (vals (send-data host (seq data))))

(defn -getStats
  [host]
  (vals (get-stats host)))

(defn -setXOffset
  [host value]
  (let [ch (get-ch host)]
    (enqueue ch (encode command-codec \x))
    (:value (decode return-int-codec (.toByteBuffer (wait-for-message ch))))))

(defn -setBrightness
  [host value]
  (let [ch (get-ch host)]
    (enqueue ch (encode command-codec \b))
    (:value (decode return-float-codec (.toByteBuffer (wait-for-message ch))))))

(defn -setContrast
  [host value]
  (let [ch (get-ch host)]
    (enqueue ch (encode command-codec \c))
    (:value (decode return-float-codec (.toByteBuffer (wait-for-message ch))))))
