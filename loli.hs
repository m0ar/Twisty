-- To play around a bit with your interpreter
-- I wrote this little front end for the various
-- parts of your program.
-- to run : runghc -iAST/:grammar/ loli.hs
{-# LANGUAGE DeriveDataTypeable #-}
module Loli where

import System.IO
import Interpreter
import Converter hiding (main)
import DataTypes
import Environment
import qualified AbsGrammar as A

import LexGrammar
import ParGrammar
import LayoutGrammar
import qualified AbsGrammar as G
import ErrM
import Control.Exception
import Data.Typeable

import Data.Map
import qualified Data.Map as M

import System.Environment as E

myLLexer = resolveLayout True . myLexer

main = do
    E.getArgs >>= \s -> case s of
        [file] -> buildEnv file >>= repl file
        []     -> repl "" startEnv
        _      -> putStrLn "Invalid arguments"

repl :: String -> Env -> IO ()
repl file env = do
    let loop = repl file env
    putStr (file ++ ">") >> hFlush stdout
    i <- getLine
    case i of
        "" -> loop
        ":q" -> return ()
        ":r" -> buildEnv file >>= repl file
        (':':'t':' ':s) -> putStrLn (show (lookupInEnv env s))
                               >> (repl file env)
        (':':'l':s) -> case words s of
            [newfile] -> do
            res <- try $ buildEnv newfile
            case (res :: Either LoliException Env) of
                Right env -> repl newfile env
                Left  err -> repl "" env
        _ -> case pExp (myLexer i) of
            Bad s -> do putStrLn s
                        loop
            Ok e -> case eval env (cExp e) of -- TODO: type check input
               (VIO io, _) -> putStrLn "running" >> io >> loop
               ((VFun _), _)   -> putStrLn "function" >> loop
               (v, _)      -> print v >> loop


buildEnv :: String -> IO Env
buildEnv ""   = do
    putStrLn "No file loaded"
    return startEnv
buildEnv file = do
    res <- try $ readFile (file ++ ".lp")
    case (res :: Either IOError String) of
        Right content -> do
            fc <- readFile (file ++ ".lp")
            sg <- readFile "sugar.lp"
            prog <- let ts = (myLLexer $ fc ++ " \n" ++ sg) in case pProgram ts of
                Bad s   -> do putStrLn s
                              throw SyntaxError
                Ok tree -> return tree
            let ds = cProgram prog
                -- TODO: type check ds
                env = addDecsToEnv env ds
            putStrLn $ "Successfully loaded " ++ file

            return env
        Left  err     -> do
            putStrLn "No such file, nothing loaded."
            throw NoSuchFile
