
type intfloat = INil | IF of int * floatint
and floatint = FNil | FI of float * intfloat

type iflist = IFlist of intfloat | FIlist of floatint
