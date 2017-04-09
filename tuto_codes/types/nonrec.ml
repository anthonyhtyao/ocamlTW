
module Thing = struct
  type 'a t = Thing of 'a

  module Collection = struct
    type nonrec 'a t = Collect of 'a t list
  end

  let create x  = Thing x
  let collect xs = Collection.Collect (List.map (fun x -> Thing x) xs)
end
