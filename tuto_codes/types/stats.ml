
(* stats.ml *)

open Unix

(* 判斷兩個檔案是否其實是一樣的
   val equal_file : Unix.stats -> Unix.stats -> bool *)
let equal_file { st_dev ; st_ino } { st_dev = st_dev' ; st_ino = st_ino' } =
  st_dev = st_dev' && st_ino = st_ino'

(* 檢查一個檔案各時間欄位儲存的內容有無互相矛盾 
   val time_consistent : Unix.stats -> bool *)
let time_consistent { st_atime ; st_mtime ; st_ctime } =
  st_atime >= st_ctime && st_ctime >= st_mtime

(* 從兩個檔案中選出佔有空間較大者，相等情況選取第一個檔案
   val bigger_file : Unix.stats -> Unix.stats -> Unix.stats *)
let bigger_file ({st_size} as f1) ({st_size = st_size'} as f2) =
  if st_size >= st_size' then f1 else f2
