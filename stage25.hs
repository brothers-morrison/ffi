module Stage25() where

import Foreign.C
import Text.Parsec

foreign export ccall "stage25_blep" c_blep :: CString -> IO CString

c_blep cfoo = do
    foo <- peekCString (cfoo :: CString)
    writeFile "/dev/leftpad" foo
    bar <- readFile "/dev/leftpad"
    (newCString bar) :: IO CString

