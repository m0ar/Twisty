import Data.Maybe
import Text.Parsec
import Data.Map
import qualified Data.Map as M

type Program = [Declaration]


data Declaration = DFunc Var Vars Exp

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


data Value = VInt Int
        | VDouble Double
        | VBoolean Bool
        | VLam Exp
        | VCon ConID [Value] -- list of values to be used as parameters
    deriving Show

type ConID = String

type Env = Map Var Value

data Lit = SLit String
        | ILit Int
        | DLit Double
        | BLit Bool
    deriving Show

addValues :: Value -> Value -> Value
addValues (VInt x) (VInt y) = VInt (x+y)

interpret :: Program -> IO Value
interpret ds =
    do
        let e = addDecsToEnv ds M.empty
        let value = eval e $ (\(DFunc v vs e) -> e)(head ds)
        return value

addDecsToEnv :: [Declaration] -> Env -> Env
addDecsToEnv [] env                         = env
addDecsToEnv ((DFunc fname vs expr):ds) env = addDecsToEnv ds (addToEnv env fname (VLam expr))
    --case expr of
        --ELam _ _ -> addDecsToEnv ds (addToEnv env fname (VLam expr M.empty))
        --_        -> env


addToEnv :: Env -> Var -> Value -> Env
addToEnv env var val = case M.lookup var env of
                Nothing  -> M.insert var val env
                Just val -> M.insert var val (M.delete var env)

eval :: Env -> Exp -> Value
eval env expr = case expr of
        (EApp (ELam var expr') e2) -> let env2 = (addToEnv env var (eval env e2)) in eval env2 expr'
        (EAdd e1 e2)      -> addValues (eval env e1) (eval env e2)
        (ELam var e)      -> eval env e
        (EVar var)        -> case lookupInEnv env var of
            Nothing  -> error $ "variable: " ++ var ++ " not found in environment: \n" ++ show env
            Just v -> v
        (ELit (ILit i))   -> (VInt i)



lookupInEnv :: Env -> Var -> Maybe Value
lookupInEnv e var = M.lookup var e


-- Show functions --
instance Show Exp where
    show e = case e of
        EApp e1 e2         -> ""
        EVar s             -> s
        ELit l             -> show l
        EAdd e1 e2         -> show e1 ++ " + " ++ show e2
        EMult e1 e2        -> show e1 ++ " * " ++ show e2






-- Example types ..
{--data Type = Int | Double | Boolean | Char | IO | Void
    deriving Show --}



-- A function consists of a name (String)
-- and a function body (Body)
-- data Func = Function String Body

-- Arguments
--data Arg = Con Type Arg | Nil

-- Function body consists of
-- a set of variables (Vars) and
-- the statement/command (Stat) to be performed
-- data Body = Body Vars Exp


{-- evalFunc :: Func -> IO ()
evalFunc (Function _ (Body _ e)) = case e of
                EPrint e' -> putStrLn (show e') --}

{-- readExpr :: String -> Maybe Func
readExpr s = Nothing --}


{-- instance Show Func where
    show (Function s b) = "function " ++ s
                                 ++ " : "
                                 ++ "\n"
                                 ++ show b
instance Show Arg where
    show a = case a of
        Nil      -> ""
        Con t a' -> (show t) ++ " -> " ++ show a' --}

{-- instance Show Body where
    show (Body vs c) = " "
                    ++ show vs
                    ++ "= "
                    ++ show c--}
