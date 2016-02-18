import Data.Maybe
import Text.Parsec
import Data.Map
import qualified Data.Map as M

type Program = [Declaration]

data Declaration = DFunc Func

-- A function consists of a name (String)
-- and a function body (Body)
data Func = Function String Body

data Exp = EApp Exp Exp
           | EVar Var
           | ELit Lit
           | EAdd Exp Exp
           | EMult Exp Exp
           | EPrint Exp
           | ELam Var Exp

type Var = String

-- A list of variables to be used in function bodies
type Vars = [Var]

-- Arguments
--data Arg = Con Type Arg | Nil


-- Function body consists of
-- a set of variables (Vars) and
-- the statement/command (Stat) to be performed
data Body = Body Vars Exp

-- Example types ..
data Type = Int | Double | Boolean | Char | IO | Void
    deriving Show

data Value = VInt Int
        | VDouble Double
        | VBoolean Bool
        | VFunc Func
        | VCon ConID [Value]

type ConID = String

type Env = Map Var Value

data Lit = SLit String
            | ILit Int
            | DLit Double
            | BLit Bool
    deriving Show

-- [DConst "main" (Appl (Var "print") (SLit "hello"))]

eval :: Program -> IO ()
eval p = undefined

evalFunc :: Func -> IO ()
evalFunc (Function _ (Body _ e)) = case e of
                EPrint e' -> putStrLn (show e')

readExpr :: String -> Maybe Func
readExpr s = Nothing


addToEnv :: Env -> Var -> Value -> Env
addToEnv e var val = case M.lookup var e of
                Nothing  -> M.insert var val e
                Just val -> M.insert var val (M.delete var e)


lookupInEnv :: Env -> Var -> Maybe Value
lookupInEnv e var = M.lookup var

-- Show functions --

instance Show Exp where
    show e = case e of
        EApp e1 e2         -> ""
        EVar s             -> s
        ELit l             -> show l
        EAdd e1 e2         -> show e1 ++ " + " ++ show e2
        EMult e1 e2        -> show e1 ++ " * " ++ show e2

instance Show Func where
    show (Function s b) = "function " ++ s
                                 ++ " : "
                                 ++ "\n"
                                 ++ show b
{-- instance Show Arg where
    show a = case a of
        Nil      -> ""
        Con t a' -> (show t) ++ " -> " ++ show a' --}

instance Show Body where
    show (Body vs c) = " "
                    ++ show vs
                    ++ "= "
                    ++ show c
