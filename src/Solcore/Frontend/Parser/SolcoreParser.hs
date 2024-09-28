{-# OPTIONS_GHC -w #-}
module Solcore.Frontend.Parser.SolcoreParser where

import Data.List.NonEmpty 

import Solcore.Frontend.Lexer.SolcoreLexer hiding (lexer)
import Solcore.Frontend.Syntax.SyntaxTree
import Solcore.Primitives.Primitives
import Language.Yul
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.20.1.1

data HappyAbsSyn 
	= HappyTerminal (Token)
	| HappyErrorToken Prelude.Int
	| HappyAbsSyn4 (CompUnit Name)
	| HappyAbsSyn5 ([Import])
	| HappyAbsSyn6 (Import)
	| HappyAbsSyn7 ([TopDecl Name])
	| HappyAbsSyn8 (TopDecl Name)
	| HappyAbsSyn9 (Pragma)
	| HappyAbsSyn10 (PragmaStatus)
	| HappyAbsSyn11 (NonEmpty Name)
	| HappyAbsSyn12 (Contract Name)
	| HappyAbsSyn13 ([ContractDecl Name])
	| HappyAbsSyn14 (ContractDecl Name)
	| HappyAbsSyn15 (TySym)
	| HappyAbsSyn16 (Field Name)
	| HappyAbsSyn17 (DataTy)
	| HappyAbsSyn18 ([Constr])
	| HappyAbsSyn19 (Constr)
	| HappyAbsSyn20 (Class Name)
	| HappyAbsSyn21 ([Signature Name])
	| HappyAbsSyn22 ([Tyvar])
	| HappyAbsSyn24 ([Pred])
	| HappyAbsSyn27 (Pred)
	| HappyAbsSyn29 (Signature Name)
	| HappyAbsSyn30 ([Param Name])
	| HappyAbsSyn31 (Param Name)
	| HappyAbsSyn32 (Instance Name)
	| HappyAbsSyn33 ([Ty])
	| HappyAbsSyn35 ([FunDef Name])
	| HappyAbsSyn37 (FunDef Name)
	| HappyAbsSyn38 (Maybe Ty)
	| HappyAbsSyn39 (Constructor Name)
	| HappyAbsSyn40 ([Stmt Name])
	| HappyAbsSyn42 (Stmt Name)
	| HappyAbsSyn43 ([Exp Name])
	| HappyAbsSyn44 (Maybe (Exp Name))
	| HappyAbsSyn45 (Exp Name)
	| HappyAbsSyn48 ([([Pat Name], [Stmt Name])])
	| HappyAbsSyn49 (([Pat Name], [Stmt Name]))
	| HappyAbsSyn50 ([Pat Name])
	| HappyAbsSyn51 (Pat Name)
	| HappyAbsSyn54 (Literal)
	| HappyAbsSyn55 (Ty)
	| HappyAbsSyn56 (([Ty], Ty))
	| HappyAbsSyn57 (Tyvar)
	| HappyAbsSyn58 ([Name])
	| HappyAbsSyn59 (Name)
	| HappyAbsSyn60 (YulBlock)
	| HappyAbsSyn62 ([YulStmt])
	| HappyAbsSyn63 (YulStmt)
	| HappyAbsSyn66 (YulCases)
	| HappyAbsSyn67 ((YLiteral, YulBlock))
	| HappyAbsSyn68 (Maybe YulBlock)
	| HappyAbsSyn71 (Maybe YulExp)
	| HappyAbsSyn74 (YulExp)
	| HappyAbsSyn75 ([YulExp])
	| HappyAbsSyn77 (YLiteral)
	| HappyAbsSyn78 (())

{- to allow type-synonyms as our monads (likely
 - with explicitly-specified bind and return)
 - in Haskell98, it seems that with
 - /type M a = .../, then /(HappyReduction M)/
 - is not allowed.  But Happy is a
 - code-generator that can just substitute it.
type HappyReduction m = 
	   Prelude.Int 
	-> (Token)
	-> HappyState (Token) (HappyStk HappyAbsSyn -> m HappyAbsSyn)
	-> [HappyState (Token) (HappyStk HappyAbsSyn -> m HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> m HappyAbsSyn
-}

action_0,
 action_1,
 action_2,
 action_3,
 action_4,
 action_5,
 action_6,
 action_7,
 action_8,
 action_9,
 action_10,
 action_11,
 action_12,
 action_13,
 action_14,
 action_15,
 action_16,
 action_17,
 action_18,
 action_19,
 action_20,
 action_21,
 action_22,
 action_23,
 action_24,
 action_25,
 action_26,
 action_27,
 action_28,
 action_29,
 action_30,
 action_31,
 action_32,
 action_33,
 action_34,
 action_35,
 action_36,
 action_37,
 action_38,
 action_39,
 action_40,
 action_41,
 action_42,
 action_43,
 action_44,
 action_45,
 action_46,
 action_47,
 action_48,
 action_49,
 action_50,
 action_51,
 action_52,
 action_53,
 action_54,
 action_55,
 action_56,
 action_57,
 action_58,
 action_59,
 action_60,
 action_61,
 action_62,
 action_63,
 action_64,
 action_65,
 action_66,
 action_67,
 action_68,
 action_69,
 action_70,
 action_71,
 action_72,
 action_73,
 action_74,
 action_75,
 action_76,
 action_77,
 action_78,
 action_79,
 action_80,
 action_81,
 action_82,
 action_83,
 action_84,
 action_85,
 action_86,
 action_87,
 action_88,
 action_89,
 action_90,
 action_91,
 action_92,
 action_93,
 action_94,
 action_95,
 action_96,
 action_97,
 action_98,
 action_99,
 action_100,
 action_101,
 action_102,
 action_103,
 action_104,
 action_105,
 action_106,
 action_107,
 action_108,
 action_109,
 action_110,
 action_111,
 action_112,
 action_113,
 action_114,
 action_115,
 action_116,
 action_117,
 action_118,
 action_119,
 action_120,
 action_121,
 action_122,
 action_123,
 action_124,
 action_125,
 action_126,
 action_127,
 action_128,
 action_129,
 action_130,
 action_131,
 action_132,
 action_133,
 action_134,
 action_135,
 action_136,
 action_137,
 action_138,
 action_139,
 action_140,
 action_141,
 action_142,
 action_143,
 action_144,
 action_145,
 action_146,
 action_147,
 action_148,
 action_149,
 action_150,
 action_151,
 action_152,
 action_153,
 action_154,
 action_155,
 action_156,
 action_157,
 action_158,
 action_159,
 action_160,
 action_161,
 action_162,
 action_163,
 action_164,
 action_165,
 action_166,
 action_167,
 action_168,
 action_169,
 action_170,
 action_171,
 action_172,
 action_173,
 action_174,
 action_175,
 action_176,
 action_177,
 action_178,
 action_179,
 action_180,
 action_181,
 action_182,
 action_183,
 action_184,
 action_185,
 action_186,
 action_187,
 action_188,
 action_189,
 action_190,
 action_191,
 action_192,
 action_193,
 action_194,
 action_195,
 action_196,
 action_197,
 action_198,
 action_199,
 action_200,
 action_201,
 action_202,
 action_203,
 action_204,
 action_205,
 action_206,
 action_207,
 action_208,
 action_209,
 action_210,
 action_211,
 action_212,
 action_213,
 action_214,
 action_215,
 action_216,
 action_217,
 action_218,
 action_219,
 action_220,
 action_221,
 action_222,
 action_223,
 action_224,
 action_225,
 action_226,
 action_227,
 action_228,
 action_229,
 action_230,
 action_231,
 action_232,
 action_233,
 action_234,
 action_235,
 action_236,
 action_237,
 action_238,
 action_239,
 action_240,
 action_241,
 action_242,
 action_243,
 action_244,
 action_245,
 action_246,
 action_247,
 action_248,
 action_249,
 action_250,
 action_251,
 action_252,
 action_253,
 action_254,
 action_255,
 action_256,
 action_257,
 action_258,
 action_259,
 action_260,
 action_261,
 action_262,
 action_263,
 action_264,
 action_265,
 action_266,
 action_267,
 action_268,
 action_269,
 action_270,
 action_271,
 action_272,
 action_273,
 action_274,
 action_275,
 action_276,
 action_277,
 action_278,
 action_279,
 action_280,
 action_281,
 action_282,
 action_283,
 action_284,
 action_285,
 action_286,
 action_287,
 action_288,
 action_289,
 action_290,
 action_291 :: () => Prelude.Int -> ({-HappyReduction (Alex) = -}
	   Prelude.Int 
	-> (Token)
	-> HappyState (Token) (HappyStk HappyAbsSyn -> (Alex) HappyAbsSyn)
	-> [HappyState (Token) (HappyStk HappyAbsSyn -> (Alex) HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> (Alex) HappyAbsSyn)

happyReduce_1,
 happyReduce_2,
 happyReduce_3,
 happyReduce_4,
 happyReduce_5,
 happyReduce_6,
 happyReduce_7,
 happyReduce_8,
 happyReduce_9,
 happyReduce_10,
 happyReduce_11,
 happyReduce_12,
 happyReduce_13,
 happyReduce_14,
 happyReduce_15,
 happyReduce_16,
 happyReduce_17,
 happyReduce_18,
 happyReduce_19,
 happyReduce_20,
 happyReduce_21,
 happyReduce_22,
 happyReduce_23,
 happyReduce_24,
 happyReduce_25,
 happyReduce_26,
 happyReduce_27,
 happyReduce_28,
 happyReduce_29,
 happyReduce_30,
 happyReduce_31,
 happyReduce_32,
 happyReduce_33,
 happyReduce_34,
 happyReduce_35,
 happyReduce_36,
 happyReduce_37,
 happyReduce_38,
 happyReduce_39,
 happyReduce_40,
 happyReduce_41,
 happyReduce_42,
 happyReduce_43,
 happyReduce_44,
 happyReduce_45,
 happyReduce_46,
 happyReduce_47,
 happyReduce_48,
 happyReduce_49,
 happyReduce_50,
 happyReduce_51,
 happyReduce_52,
 happyReduce_53,
 happyReduce_54,
 happyReduce_55,
 happyReduce_56,
 happyReduce_57,
 happyReduce_58,
 happyReduce_59,
 happyReduce_60,
 happyReduce_61,
 happyReduce_62,
 happyReduce_63,
 happyReduce_64,
 happyReduce_65,
 happyReduce_66,
 happyReduce_67,
 happyReduce_68,
 happyReduce_69,
 happyReduce_70,
 happyReduce_71,
 happyReduce_72,
 happyReduce_73,
 happyReduce_74,
 happyReduce_75,
 happyReduce_76,
 happyReduce_77,
 happyReduce_78,
 happyReduce_79,
 happyReduce_80,
 happyReduce_81,
 happyReduce_82,
 happyReduce_83,
 happyReduce_84,
 happyReduce_85,
 happyReduce_86,
 happyReduce_87,
 happyReduce_88,
 happyReduce_89,
 happyReduce_90,
 happyReduce_91,
 happyReduce_92,
 happyReduce_93,
 happyReduce_94,
 happyReduce_95,
 happyReduce_96,
 happyReduce_97,
 happyReduce_98,
 happyReduce_99,
 happyReduce_100,
 happyReduce_101,
 happyReduce_102,
 happyReduce_103,
 happyReduce_104,
 happyReduce_105,
 happyReduce_106,
 happyReduce_107,
 happyReduce_108,
 happyReduce_109,
 happyReduce_110,
 happyReduce_111,
 happyReduce_112,
 happyReduce_113,
 happyReduce_114,
 happyReduce_115,
 happyReduce_116,
 happyReduce_117,
 happyReduce_118,
 happyReduce_119,
 happyReduce_120,
 happyReduce_121,
 happyReduce_122,
 happyReduce_123,
 happyReduce_124,
 happyReduce_125,
 happyReduce_126,
 happyReduce_127,
 happyReduce_128,
 happyReduce_129,
 happyReduce_130,
 happyReduce_131,
 happyReduce_132,
 happyReduce_133,
 happyReduce_134,
 happyReduce_135,
 happyReduce_136,
 happyReduce_137,
 happyReduce_138,
 happyReduce_139,
 happyReduce_140,
 happyReduce_141,
 happyReduce_142,
 happyReduce_143,
 happyReduce_144,
 happyReduce_145,
 happyReduce_146,
 happyReduce_147,
 happyReduce_148,
 happyReduce_149,
 happyReduce_150,
 happyReduce_151,
 happyReduce_152 :: () => ({-HappyReduction (Alex) = -}
	   Prelude.Int 
	-> (Token)
	-> HappyState (Token) (HappyStk HappyAbsSyn -> (Alex) HappyAbsSyn)
	-> [HappyState (Token) (HappyStk HappyAbsSyn -> (Alex) HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> (Alex) HappyAbsSyn)

happyExpList :: Happy_Data_Array.Array Prelude.Int Prelude.Int
happyExpList = Happy_Data_Array.listArray (0,565) ([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7264,4416,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,16412,273,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,4,0,0,0,0,64,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,32768,3,0,0,0,0,16384,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,1,0,0,0,0,16,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,256,0,16384,0,0,0,0,0,4,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,2,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,156,3232,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,32768,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,256,0,0,0,0,7168,0,8,1,0,0,0,0,112,8192,1024,0,0,0,0,0,0,0,16,0,0,0,0,1792,0,16386,0,0,0,0,0,0,0,1024,0,0,0,0,4096,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,16,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,1024,0,0,1,0,0,0,0,0,0,32,0,0,0,0,0,16,0,0,0,0,0,0,256,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,512,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,4096,0,0,0,0,0,0,0,128,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,32,0,0,0,0,16384,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,64,0,0,0,0,1024,0,0,0,0,0,0,0,16,0,1024,0,0,0,0,0,0,0,8,0,0,0,0,256,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,1024,16388,19,0,0,0,0,0,2048,0,2048,0,0,0,0,16384,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,8,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,14375,7,256,0,0,0,0,0,1,2048,0,0,0,0,0,0,0,0,0,0,0,0,49152,1,128,16,0,0,0,0,1792,0,16386,0,0,0,0,0,4,0,0,0,0,0,0,28672,32770,50,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,2048,0,0,0,0,0,0,0,32,0,1,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,28672,0,32,4,0,0,0,0,64,0,4096,0,0,0,0,0,0,0,68,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,448,0,0,0,0,0,0,0,0,0,256,0,0,0,0,7168,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,28,2048,256,0,0,0,0,0,0,0,64,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,4112,19712,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,128,0,0,0,0,1024,0,0,1,0,0,0,0,0,0,128,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,4,0,0,0,0,64,0,4096,0,0,0,0,0,1,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,16384,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,64,0,0,0,0,1024,0,0,0,0,0,0,0,16,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,1,0,0,0,0,7,0,80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,4096,0,0,0,0,0,0,1792,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,64,0,0,0,0,0,7,0,0,0,0,0,0,39936,7392,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,28672,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,112,8192,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1792,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,32,0,0,0,0,0,0,16384,0,0,0,0,0,0,6144,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,448,0,5120,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,16,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,16,4,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,4096,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,448,0,5120,0,0,0,0,0,7,0,80,0,0,0,0,39936,40960,12,1,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7168,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,16,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,28,0,320,0,0,0,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_parser","CompilationUnit","ImportList","Import","TopDeclList","TopDecl","Pragma","Status","NameList","Contract","DeclList","Decl","TypeSynonym","FieldDef","DataDef","Constrs","Constr","ClassDef","ClassBody","OptParam","VarCommaList","ContextOpt","Context","ConstraintList","Constraint","Signatures","Signature","ParamList","Param","InstDef","OptTypeParam","TypeCommaList","Functions","InstBody","Function","OptRetTy","Constructor","Body","StmtList","Stmt","MatchArgList","InitOpt","Expr","FunArgs","ExprCommaList","Equations","Equation","PatCommaList","Pattern","PatternList","PatList","Literal","Type","LamType","Var","QualName","Name","AsmBlock","YulBlock","YulStmts","YulStmt","YulFor","YulSwitch","YulCases","YulCase","YulDefault","YulIf","YulVarDecl","YulOptAss","YulAssignment","IdentifierList","YulExp","YulFunArgs","YulExpCommaList","YulLiteral","OptSemi","identifier","number","stringlit","'contract'","'import'","'let'","'='","'.'","'forall'","'class'","'instance'","'if'","'for'","'switch'","'case'","'default'","'leave'","'continue'","'break'","'assembly'","'data'","'match'","'function'","'constructor'","'return'","'lam'","'type'","'no-patterson-condition'","'no-coverage-condition'","'no-bounded-variable-condition'","'pragma'","';'","':='","':'","','","'->'","'_'","'=>'","'('","')'","'{'","'}'","'|'","%eof"]
        bit_start = st Prelude.* 122
        bit_end = (st Prelude.+ 1) Prelude.* 122
        read_bit = readArrayBit happyExpList
        bits = Prelude.map read_bit [bit_start..bit_end Prelude.- 1]
        bits_indexed = Prelude.zip bits [0..121]
        token_strs_expected = Prelude.concatMap f bits_indexed
        f (Prelude.False, _) = []
        f (Prelude.True, nr) = [token_strs Prelude.!! nr]

action_0 (4) = happyGoto action_3
action_0 (5) = happyGoto action_2
action_0 _ = happyReduce_3

action_1 (5) = happyGoto action_2
action_1 _ = happyFail (happyExpListPerState 1)

action_2 (82) = happyShift action_15
action_2 (83) = happyShift action_16
action_2 (87) = happyShift action_17
action_2 (88) = happyShift action_18
action_2 (89) = happyShift action_19
action_2 (99) = happyShift action_20
action_2 (101) = happyShift action_21
action_2 (105) = happyShift action_22
action_2 (109) = happyShift action_23
action_2 (6) = happyGoto action_4
action_2 (7) = happyGoto action_5
action_2 (8) = happyGoto action_6
action_2 (9) = happyGoto action_7
action_2 (12) = happyGoto action_8
action_2 (15) = happyGoto action_9
action_2 (17) = happyGoto action_10
action_2 (20) = happyGoto action_11
action_2 (29) = happyGoto action_12
action_2 (32) = happyGoto action_13
action_2 (37) = happyGoto action_14
action_2 _ = happyReduce_6

action_3 (122) = happyAccept
action_3 _ = happyFail (happyExpListPerState 3)

action_4 _ = happyReduce_2

action_5 _ = happyReduce_1

action_6 (82) = happyShift action_15
action_6 (87) = happyShift action_17
action_6 (88) = happyShift action_18
action_6 (89) = happyShift action_19
action_6 (99) = happyShift action_20
action_6 (101) = happyShift action_21
action_6 (105) = happyShift action_22
action_6 (109) = happyShift action_23
action_6 (7) = happyGoto action_43
action_6 (8) = happyGoto action_6
action_6 (9) = happyGoto action_7
action_6 (12) = happyGoto action_8
action_6 (15) = happyGoto action_9
action_6 (17) = happyGoto action_10
action_6 (20) = happyGoto action_11
action_6 (29) = happyGoto action_12
action_6 (32) = happyGoto action_13
action_6 (37) = happyGoto action_14
action_6 _ = happyReduce_6

action_7 _ = happyReduce_13

action_8 _ = happyReduce_7

action_9 _ = happyReduce_12

action_10 _ = happyReduce_11

action_11 _ = happyReduce_9

action_12 (119) = happyShift action_42
action_12 (40) = happyGoto action_41
action_12 _ = happyFail (happyExpListPerState 12)

action_13 _ = happyReduce_10

action_14 _ = happyReduce_8

action_15 (79) = happyShift action_28
action_15 (59) = happyGoto action_40
action_15 _ = happyFail (happyExpListPerState 15)

action_16 (79) = happyShift action_28
action_16 (58) = happyGoto action_38
action_16 (59) = happyGoto action_39
action_16 _ = happyFail (happyExpListPerState 16)

action_17 (79) = happyShift action_28
action_17 (23) = happyGoto action_35
action_17 (57) = happyGoto action_36
action_17 (59) = happyGoto action_37
action_17 _ = happyFail (happyExpListPerState 17)

action_18 (79) = happyReduce_41
action_18 (117) = happyShift action_33
action_18 (24) = happyGoto action_34
action_18 (25) = happyGoto action_32
action_18 _ = happyReduce_41

action_19 (79) = happyReduce_41
action_19 (117) = happyShift action_33
action_19 (24) = happyGoto action_31
action_19 (25) = happyGoto action_32
action_19 _ = happyReduce_41

action_20 (79) = happyShift action_28
action_20 (59) = happyGoto action_30
action_20 _ = happyFail (happyExpListPerState 20)

action_21 (79) = happyShift action_28
action_21 (59) = happyGoto action_29
action_21 _ = happyFail (happyExpListPerState 21)

action_22 (79) = happyShift action_28
action_22 (59) = happyGoto action_27
action_22 _ = happyFail (happyExpListPerState 22)

action_23 (106) = happyShift action_24
action_23 (107) = happyShift action_25
action_23 (108) = happyShift action_26
action_23 _ = happyFail (happyExpListPerState 23)

action_24 (79) = happyShift action_28
action_24 (10) = happyGoto action_79
action_24 (11) = happyGoto action_76
action_24 (59) = happyGoto action_77
action_24 _ = happyReduce_18

action_25 (79) = happyShift action_28
action_25 (10) = happyGoto action_78
action_25 (11) = happyGoto action_76
action_25 (59) = happyGoto action_77
action_25 _ = happyReduce_18

action_26 (79) = happyShift action_28
action_26 (10) = happyGoto action_75
action_26 (11) = happyGoto action_76
action_26 (59) = happyGoto action_77
action_26 _ = happyReduce_18

action_27 (117) = happyShift action_59
action_27 (22) = happyGoto action_74
action_27 _ = happyReduce_38

action_28 _ = happyReduce_113

action_29 (117) = happyShift action_73
action_29 _ = happyFail (happyExpListPerState 29)

action_30 (117) = happyShift action_59
action_30 (22) = happyGoto action_72
action_30 _ = happyReduce_38

action_31 (79) = happyShift action_28
action_31 (117) = happyShift action_70
action_31 (55) = happyGoto action_71
action_31 (56) = happyGoto action_68
action_31 (59) = happyGoto action_69
action_31 _ = happyFail (happyExpListPerState 31)

action_32 _ = happyReduce_42

action_33 (79) = happyShift action_28
action_33 (117) = happyShift action_70
action_33 (26) = happyGoto action_65
action_33 (27) = happyGoto action_66
action_33 (55) = happyGoto action_67
action_33 (56) = happyGoto action_68
action_33 (59) = happyGoto action_69
action_33 _ = happyFail (happyExpListPerState 33)

action_34 (79) = happyShift action_28
action_34 (57) = happyGoto action_64
action_34 (59) = happyGoto action_37
action_34 _ = happyFail (happyExpListPerState 34)

action_35 (86) = happyShift action_63
action_35 _ = happyFail (happyExpListPerState 35)

action_36 (113) = happyShift action_62
action_36 _ = happyReduce_40

action_37 _ = happyReduce_110

action_38 (86) = happyShift action_60
action_38 (110) = happyShift action_61
action_38 _ = happyFail (happyExpListPerState 38)

action_39 _ = happyReduce_111

action_40 (117) = happyShift action_59
action_40 (22) = happyGoto action_58
action_40 _ = happyReduce_38

action_41 _ = happyReduce_64

action_42 (79) = happyShift action_28
action_42 (80) = happyShift action_50
action_42 (81) = happyShift action_51
action_42 (84) = happyShift action_52
action_42 (98) = happyShift action_53
action_42 (100) = happyShift action_54
action_42 (103) = happyShift action_55
action_42 (104) = happyShift action_56
action_42 (117) = happyShift action_57
action_42 (41) = happyGoto action_44
action_42 (42) = happyGoto action_45
action_42 (45) = happyGoto action_46
action_42 (54) = happyGoto action_47
action_42 (59) = happyGoto action_48
action_42 (60) = happyGoto action_49
action_42 _ = happyReduce_70

action_43 _ = happyReduce_5

action_44 (120) = happyShift action_116
action_44 _ = happyFail (happyExpListPerState 44)

action_45 (110) = happyShift action_115
action_45 _ = happyFail (happyExpListPerState 45)

action_46 (85) = happyShift action_113
action_46 (86) = happyShift action_114
action_46 _ = happyReduce_74

action_47 _ = happyReduce_83

action_48 (117) = happyShift action_112
action_48 (46) = happyGoto action_111
action_48 _ = happyReduce_88

action_49 _ = happyReduce_77

action_50 _ = happyReduce_105

action_51 _ = happyReduce_106

action_52 (79) = happyShift action_28
action_52 (59) = happyGoto action_110
action_52 _ = happyFail (happyExpListPerState 52)

action_53 (119) = happyShift action_109
action_53 (61) = happyGoto action_108
action_53 _ = happyFail (happyExpListPerState 53)

action_54 (79) = happyShift action_28
action_54 (80) = happyShift action_50
action_54 (81) = happyShift action_51
action_54 (104) = happyShift action_56
action_54 (117) = happyShift action_57
action_54 (43) = happyGoto action_106
action_54 (45) = happyGoto action_107
action_54 (54) = happyGoto action_47
action_54 (59) = happyGoto action_48
action_54 _ = happyFail (happyExpListPerState 54)

action_55 (79) = happyShift action_28
action_55 (80) = happyShift action_50
action_55 (81) = happyShift action_51
action_55 (104) = happyShift action_56
action_55 (117) = happyShift action_57
action_55 (45) = happyGoto action_105
action_55 (54) = happyGoto action_47
action_55 (59) = happyGoto action_48
action_55 _ = happyFail (happyExpListPerState 55)

action_56 (117) = happyShift action_104
action_56 _ = happyFail (happyExpListPerState 56)

action_57 (79) = happyShift action_28
action_57 (80) = happyShift action_50
action_57 (81) = happyShift action_51
action_57 (104) = happyShift action_56
action_57 (117) = happyShift action_57
action_57 (45) = happyGoto action_103
action_57 (54) = happyGoto action_47
action_57 (59) = happyGoto action_48
action_57 _ = happyFail (happyExpListPerState 57)

action_58 (119) = happyShift action_102
action_58 _ = happyFail (happyExpListPerState 58)

action_59 (79) = happyShift action_28
action_59 (23) = happyGoto action_101
action_59 (57) = happyGoto action_36
action_59 (59) = happyGoto action_37
action_59 _ = happyFail (happyExpListPerState 59)

action_60 (79) = happyShift action_28
action_60 (59) = happyGoto action_100
action_60 _ = happyFail (happyExpListPerState 60)

action_61 _ = happyReduce_4

action_62 (79) = happyShift action_28
action_62 (23) = happyGoto action_99
action_62 (57) = happyGoto action_36
action_62 (59) = happyGoto action_37
action_62 _ = happyFail (happyExpListPerState 62)

action_63 (117) = happyShift action_33
action_63 (25) = happyGoto action_98
action_63 _ = happyFail (happyExpListPerState 63)

action_64 (112) = happyShift action_97
action_64 _ = happyFail (happyExpListPerState 64)

action_65 (118) = happyShift action_96
action_65 _ = happyFail (happyExpListPerState 65)

action_66 (113) = happyShift action_95
action_66 _ = happyReduce_45

action_67 (112) = happyShift action_94
action_67 _ = happyFail (happyExpListPerState 67)

action_68 _ = happyReduce_108

action_69 (117) = happyShift action_93
action_69 (33) = happyGoto action_92
action_69 _ = happyReduce_58

action_70 (79) = happyShift action_28
action_70 (117) = happyShift action_70
action_70 (34) = happyGoto action_90
action_70 (55) = happyGoto action_91
action_70 (56) = happyGoto action_68
action_70 (59) = happyGoto action_69
action_70 _ = happyFail (happyExpListPerState 70)

action_71 (112) = happyShift action_89
action_71 _ = happyFail (happyExpListPerState 71)

action_72 (85) = happyShift action_88
action_72 _ = happyFail (happyExpListPerState 72)

action_73 (79) = happyShift action_28
action_73 (30) = happyGoto action_85
action_73 (31) = happyGoto action_86
action_73 (59) = happyGoto action_87
action_73 _ = happyReduce_53

action_74 (85) = happyShift action_84
action_74 _ = happyFail (happyExpListPerState 74)

action_75 (110) = happyShift action_83
action_75 _ = happyFail (happyExpListPerState 75)

action_76 _ = happyReduce_17

action_77 (113) = happyShift action_82
action_77 _ = happyReduce_20

action_78 (110) = happyShift action_81
action_78 _ = happyFail (happyExpListPerState 78)

action_79 (110) = happyShift action_80
action_79 _ = happyFail (happyExpListPerState 79)

action_80 _ = happyReduce_15

action_81 _ = happyReduce_14

action_82 (79) = happyShift action_28
action_82 (11) = happyGoto action_176
action_82 (59) = happyGoto action_77
action_82 _ = happyFail (happyExpListPerState 82)

action_83 _ = happyReduce_16

action_84 (79) = happyShift action_28
action_84 (117) = happyShift action_70
action_84 (55) = happyGoto action_175
action_84 (56) = happyGoto action_68
action_84 (59) = happyGoto action_69
action_84 _ = happyFail (happyExpListPerState 84)

action_85 (118) = happyShift action_174
action_85 _ = happyFail (happyExpListPerState 85)

action_86 (113) = happyShift action_173
action_86 _ = happyReduce_51

action_87 (112) = happyShift action_172
action_87 _ = happyReduce_55

action_88 (79) = happyShift action_28
action_88 (18) = happyGoto action_169
action_88 (19) = happyGoto action_170
action_88 (59) = happyGoto action_171
action_88 _ = happyFail (happyExpListPerState 88)

action_89 (79) = happyShift action_28
action_89 (59) = happyGoto action_168
action_89 _ = happyFail (happyExpListPerState 89)

action_90 (118) = happyShift action_167
action_90 _ = happyFail (happyExpListPerState 90)

action_91 (113) = happyShift action_166
action_91 _ = happyReduce_60

action_92 _ = happyReduce_107

action_93 (79) = happyShift action_28
action_93 (117) = happyShift action_70
action_93 (34) = happyGoto action_165
action_93 (55) = happyGoto action_91
action_93 (56) = happyGoto action_68
action_93 (59) = happyGoto action_69
action_93 _ = happyFail (happyExpListPerState 93)

action_94 (79) = happyShift action_28
action_94 (59) = happyGoto action_164
action_94 _ = happyFail (happyExpListPerState 94)

action_95 (79) = happyShift action_28
action_95 (117) = happyShift action_70
action_95 (26) = happyGoto action_163
action_95 (27) = happyGoto action_66
action_95 (55) = happyGoto action_67
action_95 (56) = happyGoto action_68
action_95 (59) = happyGoto action_69
action_95 _ = happyFail (happyExpListPerState 95)

action_96 (116) = happyShift action_162
action_96 _ = happyFail (happyExpListPerState 96)

action_97 (79) = happyShift action_28
action_97 (59) = happyGoto action_161
action_97 _ = happyFail (happyExpListPerState 97)

action_98 (101) = happyShift action_160
action_98 _ = happyFail (happyExpListPerState 98)

action_99 _ = happyReduce_39

action_100 _ = happyReduce_112

action_101 (118) = happyShift action_159
action_101 _ = happyFail (happyExpListPerState 101)

action_102 (79) = happyShift action_28
action_102 (87) = happyShift action_17
action_102 (99) = happyShift action_20
action_102 (101) = happyShift action_21
action_102 (102) = happyShift action_158
action_102 (105) = happyShift action_22
action_102 (13) = happyGoto action_150
action_102 (14) = happyGoto action_151
action_102 (15) = happyGoto action_152
action_102 (16) = happyGoto action_153
action_102 (17) = happyGoto action_154
action_102 (29) = happyGoto action_12
action_102 (37) = happyGoto action_155
action_102 (39) = happyGoto action_156
action_102 (59) = happyGoto action_157
action_102 _ = happyReduce_23

action_103 (86) = happyShift action_114
action_103 (118) = happyShift action_149
action_103 _ = happyFail (happyExpListPerState 103)

action_104 (79) = happyShift action_28
action_104 (30) = happyGoto action_148
action_104 (31) = happyGoto action_86
action_104 (59) = happyGoto action_87
action_104 _ = happyReduce_53

action_105 (86) = happyShift action_114
action_105 _ = happyReduce_75

action_106 (119) = happyShift action_147
action_106 _ = happyFail (happyExpListPerState 106)

action_107 (86) = happyShift action_114
action_107 (113) = happyShift action_146
action_107 _ = happyReduce_78

action_108 _ = happyReduce_114

action_109 (79) = happyShift action_28
action_109 (80) = happyShift action_137
action_109 (81) = happyShift action_138
action_109 (84) = happyShift action_139
action_109 (90) = happyShift action_140
action_109 (91) = happyShift action_141
action_109 (92) = happyShift action_142
action_109 (95) = happyShift action_143
action_109 (96) = happyShift action_144
action_109 (97) = happyShift action_145
action_109 (119) = happyShift action_109
action_109 (59) = happyGoto action_125
action_109 (61) = happyGoto action_126
action_109 (62) = happyGoto action_127
action_109 (63) = happyGoto action_128
action_109 (64) = happyGoto action_129
action_109 (65) = happyGoto action_130
action_109 (69) = happyGoto action_131
action_109 (70) = happyGoto action_132
action_109 (72) = happyGoto action_133
action_109 (73) = happyGoto action_134
action_109 (74) = happyGoto action_135
action_109 (77) = happyGoto action_136
action_109 _ = happyReduce_117

action_110 (85) = happyShift action_123
action_110 (112) = happyShift action_124
action_110 (44) = happyGoto action_122
action_110 _ = happyReduce_80

action_111 _ = happyReduce_82

action_112 (79) = happyShift action_28
action_112 (80) = happyShift action_50
action_112 (81) = happyShift action_51
action_112 (104) = happyShift action_56
action_112 (117) = happyShift action_57
action_112 (45) = happyGoto action_120
action_112 (47) = happyGoto action_121
action_112 (54) = happyGoto action_47
action_112 (59) = happyGoto action_48
action_112 _ = happyReduce_90

action_113 (79) = happyShift action_28
action_113 (80) = happyShift action_50
action_113 (81) = happyShift action_51
action_113 (104) = happyShift action_56
action_113 (117) = happyShift action_57
action_113 (45) = happyGoto action_119
action_113 (54) = happyGoto action_47
action_113 (59) = happyGoto action_48
action_113 _ = happyFail (happyExpListPerState 113)

action_114 (79) = happyShift action_28
action_114 (59) = happyGoto action_118
action_114 _ = happyFail (happyExpListPerState 114)

action_115 (79) = happyShift action_28
action_115 (80) = happyShift action_50
action_115 (81) = happyShift action_51
action_115 (84) = happyShift action_52
action_115 (98) = happyShift action_53
action_115 (100) = happyShift action_54
action_115 (103) = happyShift action_55
action_115 (104) = happyShift action_56
action_115 (117) = happyShift action_57
action_115 (41) = happyGoto action_117
action_115 (42) = happyGoto action_45
action_115 (45) = happyGoto action_46
action_115 (54) = happyGoto action_47
action_115 (59) = happyGoto action_48
action_115 (60) = happyGoto action_49
action_115 _ = happyReduce_70

action_116 _ = happyReduce_68

action_117 _ = happyReduce_69

action_118 (117) = happyShift action_112
action_118 (46) = happyGoto action_216
action_118 _ = happyReduce_88

action_119 (86) = happyShift action_114
action_119 _ = happyReduce_71

action_120 (86) = happyShift action_114
action_120 (113) = happyShift action_215
action_120 _ = happyReduce_89

action_121 (118) = happyShift action_214
action_121 _ = happyFail (happyExpListPerState 121)

action_122 _ = happyReduce_73

action_123 (79) = happyShift action_28
action_123 (80) = happyShift action_50
action_123 (81) = happyShift action_51
action_123 (104) = happyShift action_56
action_123 (117) = happyShift action_57
action_123 (45) = happyGoto action_213
action_123 (54) = happyGoto action_47
action_123 (59) = happyGoto action_48
action_123 _ = happyFail (happyExpListPerState 123)

action_124 (79) = happyShift action_28
action_124 (117) = happyShift action_70
action_124 (55) = happyGoto action_212
action_124 (56) = happyGoto action_68
action_124 (59) = happyGoto action_69
action_124 _ = happyFail (happyExpListPerState 124)

action_125 (111) = happyReduce_140
action_125 (113) = happyShift action_210
action_125 (117) = happyShift action_211
action_125 (75) = happyGoto action_209
action_125 _ = happyReduce_143

action_126 _ = happyReduce_119

action_127 (120) = happyShift action_208
action_127 _ = happyFail (happyExpListPerState 127)

action_128 (110) = happyShift action_207
action_128 (78) = happyGoto action_206
action_128 _ = happyReduce_152

action_129 _ = happyReduce_124

action_130 _ = happyReduce_123

action_131 _ = happyReduce_122

action_132 _ = happyReduce_120

action_133 _ = happyReduce_118

action_134 (111) = happyShift action_205
action_134 _ = happyFail (happyExpListPerState 134)

action_135 _ = happyReduce_121

action_136 _ = happyReduce_142

action_137 _ = happyReduce_149

action_138 _ = happyReduce_150

action_139 (79) = happyShift action_28
action_139 (59) = happyGoto action_203
action_139 (73) = happyGoto action_204
action_139 _ = happyFail (happyExpListPerState 139)

action_140 (79) = happyShift action_28
action_140 (80) = happyShift action_137
action_140 (81) = happyShift action_138
action_140 (59) = happyGoto action_199
action_140 (74) = happyGoto action_202
action_140 (77) = happyGoto action_136
action_140 _ = happyFail (happyExpListPerState 140)

action_141 (119) = happyShift action_109
action_141 (61) = happyGoto action_201
action_141 _ = happyFail (happyExpListPerState 141)

action_142 (79) = happyShift action_28
action_142 (80) = happyShift action_137
action_142 (81) = happyShift action_138
action_142 (59) = happyGoto action_199
action_142 (74) = happyGoto action_200
action_142 (77) = happyGoto action_136
action_142 _ = happyFail (happyExpListPerState 142)

action_143 _ = happyReduce_127

action_144 _ = happyReduce_125

action_145 _ = happyReduce_126

action_146 (79) = happyShift action_28
action_146 (80) = happyShift action_50
action_146 (81) = happyShift action_51
action_146 (104) = happyShift action_56
action_146 (117) = happyShift action_57
action_146 (43) = happyGoto action_198
action_146 (45) = happyGoto action_107
action_146 (54) = happyGoto action_47
action_146 (59) = happyGoto action_48
action_146 _ = happyFail (happyExpListPerState 146)

action_147 (121) = happyShift action_197
action_147 (48) = happyGoto action_195
action_147 (49) = happyGoto action_196
action_147 _ = happyReduce_93

action_148 (118) = happyShift action_194
action_148 _ = happyFail (happyExpListPerState 148)

action_149 _ = happyReduce_84

action_150 (120) = happyShift action_193
action_150 _ = happyFail (happyExpListPerState 150)

action_151 (79) = happyShift action_28
action_151 (87) = happyShift action_17
action_151 (99) = happyShift action_20
action_151 (101) = happyShift action_21
action_151 (102) = happyShift action_158
action_151 (105) = happyShift action_22
action_151 (13) = happyGoto action_192
action_151 (14) = happyGoto action_151
action_151 (15) = happyGoto action_152
action_151 (16) = happyGoto action_153
action_151 (17) = happyGoto action_154
action_151 (29) = happyGoto action_12
action_151 (37) = happyGoto action_155
action_151 (39) = happyGoto action_156
action_151 (59) = happyGoto action_157
action_151 _ = happyReduce_23

action_152 _ = happyReduce_28

action_153 _ = happyReduce_24

action_154 _ = happyReduce_25

action_155 _ = happyReduce_26

action_156 _ = happyReduce_27

action_157 (112) = happyShift action_191
action_157 _ = happyFail (happyExpListPerState 157)

action_158 (117) = happyShift action_190
action_158 _ = happyFail (happyExpListPerState 158)

action_159 _ = happyReduce_37

action_160 (79) = happyShift action_28
action_160 (59) = happyGoto action_189
action_160 _ = happyFail (happyExpListPerState 160)

action_161 (117) = happyShift action_59
action_161 (22) = happyGoto action_188
action_161 _ = happyReduce_38

action_162 _ = happyReduce_43

action_163 _ = happyReduce_44

action_164 (117) = happyShift action_93
action_164 (33) = happyGoto action_187
action_164 _ = happyReduce_58

action_165 (118) = happyShift action_186
action_165 _ = happyFail (happyExpListPerState 165)

action_166 (79) = happyShift action_28
action_166 (117) = happyShift action_70
action_166 (34) = happyGoto action_185
action_166 (55) = happyGoto action_91
action_166 (56) = happyGoto action_68
action_166 (59) = happyGoto action_69
action_166 _ = happyFail (happyExpListPerState 166)

action_167 (114) = happyShift action_184
action_167 _ = happyFail (happyExpListPerState 167)

action_168 (117) = happyShift action_93
action_168 (33) = happyGoto action_183
action_168 _ = happyReduce_58

action_169 _ = happyReduce_31

action_170 (121) = happyShift action_182
action_170 _ = happyReduce_33

action_171 (117) = happyShift action_93
action_171 (33) = happyGoto action_181
action_171 _ = happyReduce_58

action_172 (79) = happyShift action_28
action_172 (117) = happyShift action_70
action_172 (55) = happyGoto action_180
action_172 (56) = happyGoto action_68
action_172 (59) = happyGoto action_69
action_172 _ = happyFail (happyExpListPerState 172)

action_173 (79) = happyShift action_28
action_173 (30) = happyGoto action_179
action_173 (31) = happyGoto action_86
action_173 (59) = happyGoto action_87
action_173 _ = happyReduce_53

action_174 (114) = happyShift action_178
action_174 (38) = happyGoto action_177
action_174 _ = happyReduce_66

action_175 _ = happyReduce_29

action_176 _ = happyReduce_19

action_177 _ = happyReduce_50

action_178 (79) = happyShift action_28
action_178 (117) = happyShift action_70
action_178 (55) = happyGoto action_249
action_178 (56) = happyGoto action_68
action_178 (59) = happyGoto action_69
action_178 _ = happyFail (happyExpListPerState 178)

action_179 _ = happyReduce_52

action_180 _ = happyReduce_54

action_181 _ = happyReduce_34

action_182 (79) = happyShift action_28
action_182 (18) = happyGoto action_248
action_182 (19) = happyGoto action_170
action_182 (59) = happyGoto action_171
action_182 _ = happyFail (happyExpListPerState 182)

action_183 (119) = happyShift action_247
action_183 (36) = happyGoto action_246
action_183 _ = happyFail (happyExpListPerState 183)

action_184 (79) = happyShift action_28
action_184 (117) = happyShift action_70
action_184 (55) = happyGoto action_245
action_184 (56) = happyGoto action_68
action_184 (59) = happyGoto action_69
action_184 _ = happyFail (happyExpListPerState 184)

action_185 _ = happyReduce_59

action_186 _ = happyReduce_57

action_187 _ = happyReduce_46

action_188 (119) = happyShift action_244
action_188 (21) = happyGoto action_243
action_188 _ = happyFail (happyExpListPerState 188)

action_189 (117) = happyShift action_242
action_189 _ = happyFail (happyExpListPerState 189)

action_190 (79) = happyShift action_28
action_190 (30) = happyGoto action_241
action_190 (31) = happyGoto action_86
action_190 (59) = happyGoto action_87
action_190 _ = happyReduce_53

action_191 (79) = happyShift action_28
action_191 (117) = happyShift action_70
action_191 (55) = happyGoto action_240
action_191 (56) = happyGoto action_68
action_191 (59) = happyGoto action_69
action_191 _ = happyFail (happyExpListPerState 191)

action_192 _ = happyReduce_22

action_193 _ = happyReduce_21

action_194 (114) = happyShift action_178
action_194 (38) = happyGoto action_239
action_194 _ = happyReduce_66

action_195 (120) = happyShift action_238
action_195 _ = happyFail (happyExpListPerState 195)

action_196 (121) = happyShift action_197
action_196 (48) = happyGoto action_237
action_196 (49) = happyGoto action_196
action_196 _ = happyReduce_93

action_197 (79) = happyShift action_28
action_197 (80) = happyShift action_50
action_197 (81) = happyShift action_51
action_197 (115) = happyShift action_235
action_197 (117) = happyShift action_236
action_197 (50) = happyGoto action_231
action_197 (51) = happyGoto action_232
action_197 (54) = happyGoto action_233
action_197 (59) = happyGoto action_234
action_197 _ = happyFail (happyExpListPerState 197)

action_198 _ = happyReduce_79

action_199 (117) = happyShift action_211
action_199 (75) = happyGoto action_209
action_199 _ = happyReduce_143

action_200 (93) = happyShift action_230
action_200 (66) = happyGoto action_228
action_200 (67) = happyGoto action_229
action_200 _ = happyReduce_131

action_201 (79) = happyShift action_28
action_201 (80) = happyShift action_137
action_201 (81) = happyShift action_138
action_201 (59) = happyGoto action_199
action_201 (74) = happyGoto action_227
action_201 (77) = happyGoto action_136
action_201 _ = happyFail (happyExpListPerState 201)

action_202 (119) = happyShift action_109
action_202 (61) = happyGoto action_226
action_202 _ = happyFail (happyExpListPerState 202)

action_203 (113) = happyShift action_210
action_203 _ = happyReduce_140

action_204 (111) = happyShift action_225
action_204 (71) = happyGoto action_224
action_204 _ = happyReduce_138

action_205 (79) = happyShift action_28
action_205 (80) = happyShift action_137
action_205 (81) = happyShift action_138
action_205 (59) = happyGoto action_199
action_205 (74) = happyGoto action_223
action_205 (77) = happyGoto action_136
action_205 _ = happyFail (happyExpListPerState 205)

action_206 (79) = happyShift action_28
action_206 (80) = happyShift action_137
action_206 (81) = happyShift action_138
action_206 (84) = happyShift action_139
action_206 (90) = happyShift action_140
action_206 (91) = happyShift action_141
action_206 (92) = happyShift action_142
action_206 (95) = happyShift action_143
action_206 (96) = happyShift action_144
action_206 (97) = happyShift action_145
action_206 (119) = happyShift action_109
action_206 (59) = happyGoto action_125
action_206 (61) = happyGoto action_126
action_206 (62) = happyGoto action_222
action_206 (63) = happyGoto action_128
action_206 (64) = happyGoto action_129
action_206 (65) = happyGoto action_130
action_206 (69) = happyGoto action_131
action_206 (70) = happyGoto action_132
action_206 (72) = happyGoto action_133
action_206 (73) = happyGoto action_134
action_206 (74) = happyGoto action_135
action_206 (77) = happyGoto action_136
action_206 _ = happyReduce_117

action_207 _ = happyReduce_151

action_208 _ = happyReduce_115

action_209 _ = happyReduce_144

action_210 (79) = happyShift action_28
action_210 (59) = happyGoto action_203
action_210 (73) = happyGoto action_221
action_210 _ = happyFail (happyExpListPerState 210)

action_211 (79) = happyShift action_28
action_211 (80) = happyShift action_137
action_211 (81) = happyShift action_138
action_211 (59) = happyGoto action_199
action_211 (74) = happyGoto action_219
action_211 (76) = happyGoto action_220
action_211 (77) = happyGoto action_136
action_211 _ = happyReduce_147

action_212 (85) = happyShift action_123
action_212 (44) = happyGoto action_218
action_212 _ = happyReduce_80

action_213 (86) = happyShift action_114
action_213 _ = happyReduce_81

action_214 _ = happyReduce_87

action_215 (79) = happyShift action_28
action_215 (80) = happyShift action_50
action_215 (81) = happyShift action_51
action_215 (104) = happyShift action_56
action_215 (117) = happyShift action_57
action_215 (45) = happyGoto action_120
action_215 (47) = happyGoto action_217
action_215 (54) = happyGoto action_47
action_215 (59) = happyGoto action_48
action_215 _ = happyReduce_90

action_216 _ = happyReduce_85

action_217 _ = happyReduce_91

action_218 _ = happyReduce_72

action_219 (113) = happyShift action_270
action_219 _ = happyReduce_146

action_220 (118) = happyShift action_269
action_220 _ = happyFail (happyExpListPerState 220)

action_221 _ = happyReduce_141

action_222 _ = happyReduce_116

action_223 _ = happyReduce_139

action_224 _ = happyReduce_136

action_225 (79) = happyShift action_28
action_225 (80) = happyShift action_137
action_225 (81) = happyShift action_138
action_225 (59) = happyGoto action_199
action_225 (74) = happyGoto action_268
action_225 (77) = happyGoto action_136
action_225 _ = happyFail (happyExpListPerState 225)

action_226 _ = happyReduce_135

action_227 (119) = happyShift action_109
action_227 (61) = happyGoto action_267
action_227 _ = happyFail (happyExpListPerState 227)

action_228 (94) = happyShift action_266
action_228 (68) = happyGoto action_265
action_228 _ = happyReduce_134

action_229 (93) = happyShift action_230
action_229 (66) = happyGoto action_264
action_229 (67) = happyGoto action_229
action_229 _ = happyReduce_131

action_230 (80) = happyShift action_137
action_230 (81) = happyShift action_138
action_230 (77) = happyGoto action_263
action_230 _ = happyFail (happyExpListPerState 230)

action_231 (116) = happyShift action_262
action_231 _ = happyFail (happyExpListPerState 231)

action_232 (113) = happyShift action_261
action_232 _ = happyReduce_95

action_233 _ = happyReduce_99

action_234 (117) = happyShift action_260
action_234 (52) = happyGoto action_259
action_234 _ = happyReduce_102

action_235 _ = happyReduce_98

action_236 (79) = happyShift action_28
action_236 (80) = happyShift action_50
action_236 (81) = happyShift action_51
action_236 (115) = happyShift action_235
action_236 (117) = happyShift action_236
action_236 (51) = happyGoto action_258
action_236 (54) = happyGoto action_233
action_236 (59) = happyGoto action_234
action_236 _ = happyFail (happyExpListPerState 236)

action_237 _ = happyReduce_92

action_238 _ = happyReduce_76

action_239 (119) = happyShift action_42
action_239 (40) = happyGoto action_257
action_239 _ = happyFail (happyExpListPerState 239)

action_240 (85) = happyShift action_123
action_240 (44) = happyGoto action_256
action_240 _ = happyReduce_80

action_241 (118) = happyShift action_255
action_241 _ = happyFail (happyExpListPerState 241)

action_242 (79) = happyShift action_28
action_242 (30) = happyGoto action_254
action_242 (31) = happyGoto action_86
action_242 (59) = happyGoto action_87
action_242 _ = happyReduce_53

action_243 _ = happyReduce_35

action_244 (87) = happyShift action_17
action_244 (101) = happyShift action_21
action_244 (28) = happyGoto action_252
action_244 (29) = happyGoto action_253
action_244 _ = happyReduce_48

action_245 _ = happyReduce_109

action_246 _ = happyReduce_56

action_247 (87) = happyShift action_17
action_247 (101) = happyShift action_21
action_247 (29) = happyGoto action_12
action_247 (35) = happyGoto action_250
action_247 (37) = happyGoto action_251
action_247 _ = happyReduce_62

action_248 _ = happyReduce_32

action_249 _ = happyReduce_65

action_250 (120) = happyShift action_286
action_250 _ = happyFail (happyExpListPerState 250)

action_251 (87) = happyShift action_17
action_251 (101) = happyShift action_21
action_251 (29) = happyGoto action_12
action_251 (35) = happyGoto action_285
action_251 (37) = happyGoto action_251
action_251 _ = happyReduce_62

action_252 (120) = happyShift action_284
action_252 _ = happyFail (happyExpListPerState 252)

action_253 (110) = happyShift action_283
action_253 _ = happyFail (happyExpListPerState 253)

action_254 (118) = happyShift action_282
action_254 _ = happyFail (happyExpListPerState 254)

action_255 (119) = happyShift action_42
action_255 (40) = happyGoto action_281
action_255 _ = happyFail (happyExpListPerState 255)

action_256 (110) = happyShift action_280
action_256 _ = happyFail (happyExpListPerState 256)

action_257 _ = happyReduce_86

action_258 (118) = happyShift action_279
action_258 _ = happyFail (happyExpListPerState 258)

action_259 _ = happyReduce_97

action_260 (79) = happyShift action_28
action_260 (80) = happyShift action_50
action_260 (81) = happyShift action_51
action_260 (115) = happyShift action_235
action_260 (117) = happyShift action_236
action_260 (51) = happyGoto action_277
action_260 (53) = happyGoto action_278
action_260 (54) = happyGoto action_233
action_260 (59) = happyGoto action_234
action_260 _ = happyFail (happyExpListPerState 260)

action_261 (79) = happyShift action_28
action_261 (80) = happyShift action_50
action_261 (81) = happyShift action_51
action_261 (115) = happyShift action_235
action_261 (117) = happyShift action_236
action_261 (50) = happyGoto action_276
action_261 (51) = happyGoto action_232
action_261 (54) = happyGoto action_233
action_261 (59) = happyGoto action_234
action_261 _ = happyFail (happyExpListPerState 261)

action_262 (79) = happyShift action_28
action_262 (80) = happyShift action_50
action_262 (81) = happyShift action_51
action_262 (84) = happyShift action_52
action_262 (98) = happyShift action_53
action_262 (100) = happyShift action_54
action_262 (103) = happyShift action_55
action_262 (104) = happyShift action_56
action_262 (117) = happyShift action_57
action_262 (41) = happyGoto action_275
action_262 (42) = happyGoto action_45
action_262 (45) = happyGoto action_46
action_262 (54) = happyGoto action_47
action_262 (59) = happyGoto action_48
action_262 (60) = happyGoto action_49
action_262 _ = happyReduce_70

action_263 (119) = happyShift action_109
action_263 (61) = happyGoto action_274
action_263 _ = happyFail (happyExpListPerState 263)

action_264 _ = happyReduce_130

action_265 _ = happyReduce_129

action_266 (119) = happyShift action_109
action_266 (61) = happyGoto action_273
action_266 _ = happyFail (happyExpListPerState 266)

action_267 (119) = happyShift action_109
action_267 (61) = happyGoto action_272
action_267 _ = happyFail (happyExpListPerState 267)

action_268 _ = happyReduce_137

action_269 _ = happyReduce_145

action_270 (79) = happyShift action_28
action_270 (80) = happyShift action_137
action_270 (81) = happyShift action_138
action_270 (59) = happyGoto action_199
action_270 (74) = happyGoto action_219
action_270 (76) = happyGoto action_271
action_270 (77) = happyGoto action_136
action_270 _ = happyReduce_147

action_271 _ = happyReduce_148

action_272 _ = happyReduce_128

action_273 _ = happyReduce_133

action_274 _ = happyReduce_132

action_275 _ = happyReduce_94

action_276 _ = happyReduce_96

action_277 (113) = happyShift action_290
action_277 _ = happyReduce_103

action_278 (118) = happyShift action_289
action_278 _ = happyFail (happyExpListPerState 278)

action_279 _ = happyReduce_100

action_280 _ = happyReduce_30

action_281 _ = happyReduce_67

action_282 (114) = happyShift action_178
action_282 (38) = happyGoto action_288
action_282 _ = happyReduce_66

action_283 (87) = happyShift action_17
action_283 (101) = happyShift action_21
action_283 (28) = happyGoto action_287
action_283 (29) = happyGoto action_253
action_283 _ = happyReduce_48

action_284 _ = happyReduce_36

action_285 _ = happyReduce_61

action_286 _ = happyReduce_63

action_287 _ = happyReduce_47

action_288 _ = happyReduce_49

action_289 _ = happyReduce_101

action_290 (79) = happyShift action_28
action_290 (80) = happyShift action_50
action_290 (81) = happyShift action_51
action_290 (115) = happyShift action_235
action_290 (117) = happyShift action_236
action_290 (51) = happyGoto action_277
action_290 (53) = happyGoto action_291
action_290 (54) = happyGoto action_233
action_290 (59) = happyGoto action_234
action_290 _ = happyFail (happyExpListPerState 290)

action_291 _ = happyReduce_104

happyReduce_1 = happySpecReduce_2  4 happyReduction_1
happyReduction_1 (HappyAbsSyn7  happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn4
		 (CompUnit happy_var_1 happy_var_2
	)
happyReduction_1 _ _  = notHappyAtAll 

happyReduce_2 = happySpecReduce_2  5 happyReduction_2
happyReduction_2 (HappyAbsSyn6  happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (happy_var_2 : happy_var_1
	)
happyReduction_2 _ _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_0  5 happyReduction_3
happyReduction_3  =  HappyAbsSyn5
		 ([]
	)

happyReduce_4 = happySpecReduce_3  6 happyReduction_4
happyReduction_4 _
	(HappyAbsSyn58  happy_var_2)
	_
	 =  HappyAbsSyn6
		 (Import (QualName happy_var_2)
	)
happyReduction_4 _ _ _  = notHappyAtAll 

happyReduce_5 = happySpecReduce_2  7 happyReduction_5
happyReduction_5 (HappyAbsSyn7  happy_var_2)
	(HappyAbsSyn8  happy_var_1)
	 =  HappyAbsSyn7
		 (happy_var_1 : happy_var_2
	)
happyReduction_5 _ _  = notHappyAtAll 

happyReduce_6 = happySpecReduce_0  7 happyReduction_6
happyReduction_6  =  HappyAbsSyn7
		 ([]
	)

happyReduce_7 = happySpecReduce_1  8 happyReduction_7
happyReduction_7 (HappyAbsSyn12  happy_var_1)
	 =  HappyAbsSyn8
		 (TContr happy_var_1
	)
happyReduction_7 _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_1  8 happyReduction_8
happyReduction_8 (HappyAbsSyn37  happy_var_1)
	 =  HappyAbsSyn8
		 (TFunDef happy_var_1
	)
happyReduction_8 _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_1  8 happyReduction_9
happyReduction_9 (HappyAbsSyn20  happy_var_1)
	 =  HappyAbsSyn8
		 (TClassDef happy_var_1
	)
happyReduction_9 _  = notHappyAtAll 

happyReduce_10 = happySpecReduce_1  8 happyReduction_10
happyReduction_10 (HappyAbsSyn32  happy_var_1)
	 =  HappyAbsSyn8
		 (TInstDef happy_var_1
	)
happyReduction_10 _  = notHappyAtAll 

happyReduce_11 = happySpecReduce_1  8 happyReduction_11
happyReduction_11 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn8
		 (TDataDef happy_var_1
	)
happyReduction_11 _  = notHappyAtAll 

happyReduce_12 = happySpecReduce_1  8 happyReduction_12
happyReduction_12 (HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn8
		 (TSym happy_var_1
	)
happyReduction_12 _  = notHappyAtAll 

happyReduce_13 = happySpecReduce_1  8 happyReduction_13
happyReduction_13 (HappyAbsSyn9  happy_var_1)
	 =  HappyAbsSyn8
		 (TPragmaDecl happy_var_1
	)
happyReduction_13 _  = notHappyAtAll 

happyReduce_14 = happyReduce 4 9 happyReduction_14
happyReduction_14 (_ `HappyStk`
	(HappyAbsSyn10  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn9
		 (Pragma NoCoverageCondition happy_var_3
	) `HappyStk` happyRest

happyReduce_15 = happyReduce 4 9 happyReduction_15
happyReduction_15 (_ `HappyStk`
	(HappyAbsSyn10  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn9
		 (Pragma NoPattersonCondition happy_var_3
	) `HappyStk` happyRest

happyReduce_16 = happyReduce 4 9 happyReduction_16
happyReduction_16 (_ `HappyStk`
	(HappyAbsSyn10  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn9
		 (Pragma NoBoundVariableCondition happy_var_3
	) `HappyStk` happyRest

happyReduce_17 = happySpecReduce_1  10 happyReduction_17
happyReduction_17 (HappyAbsSyn11  happy_var_1)
	 =  HappyAbsSyn10
		 (DisableFor happy_var_1
	)
happyReduction_17 _  = notHappyAtAll 

happyReduce_18 = happySpecReduce_0  10 happyReduction_18
happyReduction_18  =  HappyAbsSyn10
		 (DisableAll
	)

happyReduce_19 = happySpecReduce_3  11 happyReduction_19
happyReduction_19 (HappyAbsSyn11  happy_var_3)
	_
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn11
		 (cons happy_var_1 happy_var_3
	)
happyReduction_19 _ _ _  = notHappyAtAll 

happyReduce_20 = happySpecReduce_1  11 happyReduction_20
happyReduction_20 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn11
		 (singleton happy_var_1
	)
happyReduction_20 _  = notHappyAtAll 

happyReduce_21 = happyReduce 6 12 happyReduction_21
happyReduction_21 (_ `HappyStk`
	(HappyAbsSyn13  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn22  happy_var_3) `HappyStk`
	(HappyAbsSyn59  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn12
		 (Contract happy_var_2 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_22 = happySpecReduce_2  13 happyReduction_22
happyReduction_22 (HappyAbsSyn13  happy_var_2)
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn13
		 (happy_var_1 : happy_var_2
	)
happyReduction_22 _ _  = notHappyAtAll 

happyReduce_23 = happySpecReduce_0  13 happyReduction_23
happyReduction_23  =  HappyAbsSyn13
		 ([]
	)

happyReduce_24 = happySpecReduce_1  14 happyReduction_24
happyReduction_24 (HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn14
		 (CFieldDecl happy_var_1
	)
happyReduction_24 _  = notHappyAtAll 

happyReduce_25 = happySpecReduce_1  14 happyReduction_25
happyReduction_25 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn14
		 (CDataDecl happy_var_1
	)
happyReduction_25 _  = notHappyAtAll 

happyReduce_26 = happySpecReduce_1  14 happyReduction_26
happyReduction_26 (HappyAbsSyn37  happy_var_1)
	 =  HappyAbsSyn14
		 (CFunDecl happy_var_1
	)
happyReduction_26 _  = notHappyAtAll 

happyReduce_27 = happySpecReduce_1  14 happyReduction_27
happyReduction_27 (HappyAbsSyn39  happy_var_1)
	 =  HappyAbsSyn14
		 (CConstrDecl happy_var_1
	)
happyReduction_27 _  = notHappyAtAll 

happyReduce_28 = happySpecReduce_1  14 happyReduction_28
happyReduction_28 (HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn14
		 (CSym happy_var_1
	)
happyReduction_28 _  = notHappyAtAll 

happyReduce_29 = happyReduce 5 15 happyReduction_29
happyReduction_29 ((HappyAbsSyn55  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn22  happy_var_3) `HappyStk`
	(HappyAbsSyn59  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn15
		 (TySym happy_var_2 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_30 = happyReduce 5 16 happyReduction_30
happyReduction_30 (_ `HappyStk`
	(HappyAbsSyn44  happy_var_4) `HappyStk`
	(HappyAbsSyn55  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn59  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn16
		 (Field happy_var_1 happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_31 = happyReduce 5 17 happyReduction_31
happyReduction_31 ((HappyAbsSyn18  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn22  happy_var_3) `HappyStk`
	(HappyAbsSyn59  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 (DataTy happy_var_2 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_32 = happySpecReduce_3  18 happyReduction_32
happyReduction_32 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn19  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1 : happy_var_3
	)
happyReduction_32 _ _ _  = notHappyAtAll 

happyReduce_33 = happySpecReduce_1  18 happyReduction_33
happyReduction_33 (HappyAbsSyn19  happy_var_1)
	 =  HappyAbsSyn18
		 ([happy_var_1]
	)
happyReduction_33 _  = notHappyAtAll 

happyReduce_34 = happySpecReduce_2  19 happyReduction_34
happyReduction_34 (HappyAbsSyn33  happy_var_2)
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn19
		 (Constr happy_var_1 happy_var_2
	)
happyReduction_34 _ _  = notHappyAtAll 

happyReduce_35 = happyReduce 7 20 happyReduction_35
happyReduction_35 ((HappyAbsSyn21  happy_var_7) `HappyStk`
	(HappyAbsSyn22  happy_var_6) `HappyStk`
	(HappyAbsSyn59  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn57  happy_var_3) `HappyStk`
	(HappyAbsSyn24  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn20
		 (Class happy_var_2 happy_var_5 happy_var_6 happy_var_3 happy_var_7
	) `HappyStk` happyRest

happyReduce_36 = happySpecReduce_3  21 happyReduction_36
happyReduction_36 _
	(HappyAbsSyn21  happy_var_2)
	_
	 =  HappyAbsSyn21
		 (happy_var_2
	)
happyReduction_36 _ _ _  = notHappyAtAll 

happyReduce_37 = happySpecReduce_3  22 happyReduction_37
happyReduction_37 _
	(HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn22
		 (happy_var_2
	)
happyReduction_37 _ _ _  = notHappyAtAll 

happyReduce_38 = happySpecReduce_0  22 happyReduction_38
happyReduction_38  =  HappyAbsSyn22
		 ([]
	)

happyReduce_39 = happySpecReduce_3  23 happyReduction_39
happyReduction_39 (HappyAbsSyn22  happy_var_3)
	_
	(HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn22
		 (happy_var_1 : happy_var_3
	)
happyReduction_39 _ _ _  = notHappyAtAll 

happyReduce_40 = happySpecReduce_1  23 happyReduction_40
happyReduction_40 (HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn22
		 ([happy_var_1]
	)
happyReduction_40 _  = notHappyAtAll 

happyReduce_41 = happySpecReduce_0  24 happyReduction_41
happyReduction_41  =  HappyAbsSyn24
		 ([]
	)

happyReduce_42 = happySpecReduce_1  24 happyReduction_42
happyReduction_42 (HappyAbsSyn24  happy_var_1)
	 =  HappyAbsSyn24
		 (happy_var_1
	)
happyReduction_42 _  = notHappyAtAll 

happyReduce_43 = happyReduce 4 25 happyReduction_43
happyReduction_43 (_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn24  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn24
		 (happy_var_2
	) `HappyStk` happyRest

happyReduce_44 = happySpecReduce_3  26 happyReduction_44
happyReduction_44 (HappyAbsSyn24  happy_var_3)
	_
	(HappyAbsSyn27  happy_var_1)
	 =  HappyAbsSyn24
		 (happy_var_1 : happy_var_3
	)
happyReduction_44 _ _ _  = notHappyAtAll 

happyReduce_45 = happySpecReduce_1  26 happyReduction_45
happyReduction_45 (HappyAbsSyn27  happy_var_1)
	 =  HappyAbsSyn24
		 ([happy_var_1]
	)
happyReduction_45 _  = notHappyAtAll 

happyReduce_46 = happyReduce 4 27 happyReduction_46
happyReduction_46 ((HappyAbsSyn33  happy_var_4) `HappyStk`
	(HappyAbsSyn59  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn55  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn27
		 (InCls happy_var_3 happy_var_1 happy_var_4
	) `HappyStk` happyRest

happyReduce_47 = happySpecReduce_3  28 happyReduction_47
happyReduction_47 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn29  happy_var_1)
	 =  HappyAbsSyn21
		 (happy_var_1 : happy_var_3
	)
happyReduction_47 _ _ _  = notHappyAtAll 

happyReduce_48 = happySpecReduce_0  28 happyReduction_48
happyReduction_48  =  HappyAbsSyn21
		 ([]
	)

happyReduce_49 = happyReduce 10 29 happyReduction_49
happyReduction_49 ((HappyAbsSyn38  happy_var_10) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn30  happy_var_8) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn59  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn24  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn22  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Signature happy_var_2 happy_var_4 happy_var_6 happy_var_8 happy_var_10
	) `HappyStk` happyRest

happyReduce_50 = happyReduce 6 29 happyReduction_50
happyReduction_50 ((HappyAbsSyn38  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn30  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn59  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Signature [] [] happy_var_2 happy_var_4 happy_var_6
	) `HappyStk` happyRest

happyReduce_51 = happySpecReduce_1  30 happyReduction_51
happyReduction_51 (HappyAbsSyn31  happy_var_1)
	 =  HappyAbsSyn30
		 ([happy_var_1]
	)
happyReduction_51 _  = notHappyAtAll 

happyReduce_52 = happySpecReduce_3  30 happyReduction_52
happyReduction_52 (HappyAbsSyn30  happy_var_3)
	_
	(HappyAbsSyn31  happy_var_1)
	 =  HappyAbsSyn30
		 (happy_var_1 : happy_var_3
	)
happyReduction_52 _ _ _  = notHappyAtAll 

happyReduce_53 = happySpecReduce_0  30 happyReduction_53
happyReduction_53  =  HappyAbsSyn30
		 ([]
	)

happyReduce_54 = happySpecReduce_3  31 happyReduction_54
happyReduction_54 (HappyAbsSyn55  happy_var_3)
	_
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn31
		 (Typed happy_var_1 happy_var_3
	)
happyReduction_54 _ _ _  = notHappyAtAll 

happyReduce_55 = happySpecReduce_1  31 happyReduction_55
happyReduction_55 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn31
		 (Untyped happy_var_1
	)
happyReduction_55 _  = notHappyAtAll 

happyReduce_56 = happyReduce 7 32 happyReduction_56
happyReduction_56 ((HappyAbsSyn35  happy_var_7) `HappyStk`
	(HappyAbsSyn33  happy_var_6) `HappyStk`
	(HappyAbsSyn59  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn55  happy_var_3) `HappyStk`
	(HappyAbsSyn24  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn32
		 (Instance happy_var_2 happy_var_5 happy_var_6 happy_var_3 happy_var_7
	) `HappyStk` happyRest

happyReduce_57 = happySpecReduce_3  33 happyReduction_57
happyReduction_57 _
	(HappyAbsSyn33  happy_var_2)
	_
	 =  HappyAbsSyn33
		 (happy_var_2
	)
happyReduction_57 _ _ _  = notHappyAtAll 

happyReduce_58 = happySpecReduce_0  33 happyReduction_58
happyReduction_58  =  HappyAbsSyn33
		 ([]
	)

happyReduce_59 = happySpecReduce_3  34 happyReduction_59
happyReduction_59 (HappyAbsSyn33  happy_var_3)
	_
	(HappyAbsSyn55  happy_var_1)
	 =  HappyAbsSyn33
		 (happy_var_1 : happy_var_3
	)
happyReduction_59 _ _ _  = notHappyAtAll 

happyReduce_60 = happySpecReduce_1  34 happyReduction_60
happyReduction_60 (HappyAbsSyn55  happy_var_1)
	 =  HappyAbsSyn33
		 ([happy_var_1]
	)
happyReduction_60 _  = notHappyAtAll 

happyReduce_61 = happySpecReduce_2  35 happyReduction_61
happyReduction_61 (HappyAbsSyn35  happy_var_2)
	(HappyAbsSyn37  happy_var_1)
	 =  HappyAbsSyn35
		 (happy_var_1 : happy_var_2
	)
happyReduction_61 _ _  = notHappyAtAll 

happyReduce_62 = happySpecReduce_0  35 happyReduction_62
happyReduction_62  =  HappyAbsSyn35
		 ([]
	)

happyReduce_63 = happySpecReduce_3  36 happyReduction_63
happyReduction_63 _
	(HappyAbsSyn35  happy_var_2)
	_
	 =  HappyAbsSyn35
		 (happy_var_2
	)
happyReduction_63 _ _ _  = notHappyAtAll 

happyReduce_64 = happySpecReduce_2  37 happyReduction_64
happyReduction_64 (HappyAbsSyn40  happy_var_2)
	(HappyAbsSyn29  happy_var_1)
	 =  HappyAbsSyn37
		 (FunDef happy_var_1 happy_var_2
	)
happyReduction_64 _ _  = notHappyAtAll 

happyReduce_65 = happySpecReduce_2  38 happyReduction_65
happyReduction_65 (HappyAbsSyn55  happy_var_2)
	_
	 =  HappyAbsSyn38
		 (Just happy_var_2
	)
happyReduction_65 _ _  = notHappyAtAll 

happyReduce_66 = happySpecReduce_0  38 happyReduction_66
happyReduction_66  =  HappyAbsSyn38
		 (Nothing
	)

happyReduce_67 = happyReduce 5 39 happyReduction_67
happyReduction_67 ((HappyAbsSyn40  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn30  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn39
		 (Constructor happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_68 = happySpecReduce_3  40 happyReduction_68
happyReduction_68 _
	(HappyAbsSyn40  happy_var_2)
	_
	 =  HappyAbsSyn40
		 (happy_var_2
	)
happyReduction_68 _ _ _  = notHappyAtAll 

happyReduce_69 = happySpecReduce_3  41 happyReduction_69
happyReduction_69 (HappyAbsSyn40  happy_var_3)
	_
	(HappyAbsSyn42  happy_var_1)
	 =  HappyAbsSyn40
		 (happy_var_1 : happy_var_3
	)
happyReduction_69 _ _ _  = notHappyAtAll 

happyReduce_70 = happySpecReduce_0  41 happyReduction_70
happyReduction_70  =  HappyAbsSyn40
		 ([]
	)

happyReduce_71 = happySpecReduce_3  42 happyReduction_71
happyReduction_71 (HappyAbsSyn45  happy_var_3)
	_
	(HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn42
		 (happy_var_1 := happy_var_3
	)
happyReduction_71 _ _ _  = notHappyAtAll 

happyReduce_72 = happyReduce 5 42 happyReduction_72
happyReduction_72 ((HappyAbsSyn44  happy_var_5) `HappyStk`
	(HappyAbsSyn55  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn59  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn42
		 (Let happy_var_2 (Just happy_var_4) happy_var_5
	) `HappyStk` happyRest

happyReduce_73 = happySpecReduce_3  42 happyReduction_73
happyReduction_73 (HappyAbsSyn44  happy_var_3)
	(HappyAbsSyn59  happy_var_2)
	_
	 =  HappyAbsSyn42
		 (Let happy_var_2 Nothing happy_var_3
	)
happyReduction_73 _ _ _  = notHappyAtAll 

happyReduce_74 = happySpecReduce_1  42 happyReduction_74
happyReduction_74 (HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn42
		 (StmtExp happy_var_1
	)
happyReduction_74 _  = notHappyAtAll 

happyReduce_75 = happySpecReduce_2  42 happyReduction_75
happyReduction_75 (HappyAbsSyn45  happy_var_2)
	_
	 =  HappyAbsSyn42
		 (Return happy_var_2
	)
happyReduction_75 _ _  = notHappyAtAll 

happyReduce_76 = happyReduce 5 42 happyReduction_76
happyReduction_76 (_ `HappyStk`
	(HappyAbsSyn48  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn43  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn42
		 (Match happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_77 = happySpecReduce_1  42 happyReduction_77
happyReduction_77 (HappyAbsSyn60  happy_var_1)
	 =  HappyAbsSyn42
		 (Asm happy_var_1
	)
happyReduction_77 _  = notHappyAtAll 

happyReduce_78 = happySpecReduce_1  43 happyReduction_78
happyReduction_78 (HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn43
		 ([happy_var_1]
	)
happyReduction_78 _  = notHappyAtAll 

happyReduce_79 = happySpecReduce_3  43 happyReduction_79
happyReduction_79 (HappyAbsSyn43  happy_var_3)
	_
	(HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn43
		 (happy_var_1 : happy_var_3
	)
happyReduction_79 _ _ _  = notHappyAtAll 

happyReduce_80 = happySpecReduce_0  44 happyReduction_80
happyReduction_80  =  HappyAbsSyn44
		 (Nothing
	)

happyReduce_81 = happySpecReduce_2  44 happyReduction_81
happyReduction_81 (HappyAbsSyn45  happy_var_2)
	_
	 =  HappyAbsSyn44
		 (Just happy_var_2
	)
happyReduction_81 _ _  = notHappyAtAll 

happyReduce_82 = happySpecReduce_2  45 happyReduction_82
happyReduction_82 (HappyAbsSyn43  happy_var_2)
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn45
		 (ExpName Nothing happy_var_1 happy_var_2
	)
happyReduction_82 _ _  = notHappyAtAll 

happyReduce_83 = happySpecReduce_1  45 happyReduction_83
happyReduction_83 (HappyAbsSyn54  happy_var_1)
	 =  HappyAbsSyn45
		 (Lit happy_var_1
	)
happyReduction_83 _  = notHappyAtAll 

happyReduce_84 = happySpecReduce_3  45 happyReduction_84
happyReduction_84 _
	(HappyAbsSyn45  happy_var_2)
	_
	 =  HappyAbsSyn45
		 (happy_var_2
	)
happyReduction_84 _ _ _  = notHappyAtAll 

happyReduce_85 = happyReduce 4 45 happyReduction_85
happyReduction_85 ((HappyAbsSyn43  happy_var_4) `HappyStk`
	(HappyAbsSyn59  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn45  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn45
		 (ExpName (Just happy_var_1) happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_86 = happyReduce 6 45 happyReduction_86
happyReduction_86 ((HappyAbsSyn40  happy_var_6) `HappyStk`
	(HappyAbsSyn38  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn30  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn45
		 (Lam happy_var_3 happy_var_6 happy_var_5
	) `HappyStk` happyRest

happyReduce_87 = happySpecReduce_3  46 happyReduction_87
happyReduction_87 _
	(HappyAbsSyn43  happy_var_2)
	_
	 =  HappyAbsSyn43
		 (happy_var_2
	)
happyReduction_87 _ _ _  = notHappyAtAll 

happyReduce_88 = happySpecReduce_0  46 happyReduction_88
happyReduction_88  =  HappyAbsSyn43
		 ([]
	)

happyReduce_89 = happySpecReduce_1  47 happyReduction_89
happyReduction_89 (HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn43
		 ([happy_var_1]
	)
happyReduction_89 _  = notHappyAtAll 

happyReduce_90 = happySpecReduce_0  47 happyReduction_90
happyReduction_90  =  HappyAbsSyn43
		 ([]
	)

happyReduce_91 = happySpecReduce_3  47 happyReduction_91
happyReduction_91 (HappyAbsSyn43  happy_var_3)
	_
	(HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn43
		 (happy_var_1 : happy_var_3
	)
happyReduction_91 _ _ _  = notHappyAtAll 

happyReduce_92 = happySpecReduce_2  48 happyReduction_92
happyReduction_92 (HappyAbsSyn48  happy_var_2)
	(HappyAbsSyn49  happy_var_1)
	 =  HappyAbsSyn48
		 (happy_var_1 : happy_var_2
	)
happyReduction_92 _ _  = notHappyAtAll 

happyReduce_93 = happySpecReduce_0  48 happyReduction_93
happyReduction_93  =  HappyAbsSyn48
		 ([]
	)

happyReduce_94 = happyReduce 4 49 happyReduction_94
happyReduction_94 ((HappyAbsSyn40  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn50  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn49
		 ((happy_var_2, happy_var_4)
	) `HappyStk` happyRest

happyReduce_95 = happySpecReduce_1  50 happyReduction_95
happyReduction_95 (HappyAbsSyn51  happy_var_1)
	 =  HappyAbsSyn50
		 ([happy_var_1]
	)
happyReduction_95 _  = notHappyAtAll 

happyReduce_96 = happySpecReduce_3  50 happyReduction_96
happyReduction_96 (HappyAbsSyn50  happy_var_3)
	_
	(HappyAbsSyn51  happy_var_1)
	 =  HappyAbsSyn50
		 (happy_var_1 : happy_var_3
	)
happyReduction_96 _ _ _  = notHappyAtAll 

happyReduce_97 = happySpecReduce_2  51 happyReduction_97
happyReduction_97 (HappyAbsSyn50  happy_var_2)
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn51
		 (PCon happy_var_1 happy_var_2
	)
happyReduction_97 _ _  = notHappyAtAll 

happyReduce_98 = happySpecReduce_1  51 happyReduction_98
happyReduction_98 _
	 =  HappyAbsSyn51
		 (PWildcard
	)

happyReduce_99 = happySpecReduce_1  51 happyReduction_99
happyReduction_99 (HappyAbsSyn54  happy_var_1)
	 =  HappyAbsSyn51
		 (PLit happy_var_1
	)
happyReduction_99 _  = notHappyAtAll 

happyReduce_100 = happySpecReduce_3  51 happyReduction_100
happyReduction_100 _
	(HappyAbsSyn51  happy_var_2)
	_
	 =  HappyAbsSyn51
		 (happy_var_2
	)
happyReduction_100 _ _ _  = notHappyAtAll 

happyReduce_101 = happySpecReduce_3  52 happyReduction_101
happyReduction_101 _
	(HappyAbsSyn50  happy_var_2)
	_
	 =  HappyAbsSyn50
		 (happy_var_2
	)
happyReduction_101 _ _ _  = notHappyAtAll 

happyReduce_102 = happySpecReduce_0  52 happyReduction_102
happyReduction_102  =  HappyAbsSyn50
		 ([]
	)

happyReduce_103 = happySpecReduce_1  53 happyReduction_103
happyReduction_103 (HappyAbsSyn51  happy_var_1)
	 =  HappyAbsSyn50
		 ([happy_var_1]
	)
happyReduction_103 _  = notHappyAtAll 

happyReduce_104 = happySpecReduce_3  53 happyReduction_104
happyReduction_104 (HappyAbsSyn50  happy_var_3)
	_
	(HappyAbsSyn51  happy_var_1)
	 =  HappyAbsSyn50
		 (happy_var_1 : happy_var_3
	)
happyReduction_104 _ _ _  = notHappyAtAll 

happyReduce_105 = happySpecReduce_1  54 happyReduction_105
happyReduction_105 (HappyTerminal (Token _ (TNumber happy_var_1)))
	 =  HappyAbsSyn54
		 (IntLit $ toInteger happy_var_1
	)
happyReduction_105 _  = notHappyAtAll 

happyReduce_106 = happySpecReduce_1  54 happyReduction_106
happyReduction_106 (HappyTerminal (Token _ (TString happy_var_1)))
	 =  HappyAbsSyn54
		 (StrLit happy_var_1
	)
happyReduction_106 _  = notHappyAtAll 

happyReduce_107 = happySpecReduce_2  55 happyReduction_107
happyReduction_107 (HappyAbsSyn33  happy_var_2)
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn55
		 (TyCon happy_var_1 happy_var_2
	)
happyReduction_107 _ _  = notHappyAtAll 

happyReduce_108 = happySpecReduce_1  55 happyReduction_108
happyReduction_108 (HappyAbsSyn56  happy_var_1)
	 =  HappyAbsSyn55
		 (uncurry funtype happy_var_1
	)
happyReduction_108 _  = notHappyAtAll 

happyReduce_109 = happyReduce 5 56 happyReduction_109
happyReduction_109 ((HappyAbsSyn55  happy_var_5) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn56
		 ((happy_var_2, happy_var_5)
	) `HappyStk` happyRest

happyReduce_110 = happySpecReduce_1  57 happyReduction_110
happyReduction_110 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn57
		 (TVar happy_var_1
	)
happyReduction_110 _  = notHappyAtAll 

happyReduce_111 = happySpecReduce_1  58 happyReduction_111
happyReduction_111 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn58
		 ([happy_var_1]
	)
happyReduction_111 _  = notHappyAtAll 

happyReduce_112 = happySpecReduce_3  58 happyReduction_112
happyReduction_112 (HappyAbsSyn59  happy_var_3)
	_
	(HappyAbsSyn58  happy_var_1)
	 =  HappyAbsSyn58
		 (happy_var_3 : happy_var_1
	)
happyReduction_112 _ _ _  = notHappyAtAll 

happyReduce_113 = happySpecReduce_1  59 happyReduction_113
happyReduction_113 (HappyTerminal (Token _ (TIdent happy_var_1)))
	 =  HappyAbsSyn59
		 (Name happy_var_1
	)
happyReduction_113 _  = notHappyAtAll 

happyReduce_114 = happySpecReduce_2  60 happyReduction_114
happyReduction_114 (HappyAbsSyn60  happy_var_2)
	_
	 =  HappyAbsSyn60
		 (happy_var_2
	)
happyReduction_114 _ _  = notHappyAtAll 

happyReduce_115 = happySpecReduce_3  61 happyReduction_115
happyReduction_115 _
	(HappyAbsSyn62  happy_var_2)
	_
	 =  HappyAbsSyn60
		 (happy_var_2
	)
happyReduction_115 _ _ _  = notHappyAtAll 

happyReduce_116 = happySpecReduce_3  62 happyReduction_116
happyReduction_116 (HappyAbsSyn62  happy_var_3)
	_
	(HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn62
		 (happy_var_1 : happy_var_3
	)
happyReduction_116 _ _ _  = notHappyAtAll 

happyReduce_117 = happySpecReduce_0  62 happyReduction_117
happyReduction_117  =  HappyAbsSyn62
		 ([]
	)

happyReduce_118 = happySpecReduce_1  63 happyReduction_118
happyReduction_118 (HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn63
		 (happy_var_1
	)
happyReduction_118 _  = notHappyAtAll 

happyReduce_119 = happySpecReduce_1  63 happyReduction_119
happyReduction_119 (HappyAbsSyn60  happy_var_1)
	 =  HappyAbsSyn63
		 (YBlock happy_var_1
	)
happyReduction_119 _  = notHappyAtAll 

happyReduce_120 = happySpecReduce_1  63 happyReduction_120
happyReduction_120 (HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn63
		 (happy_var_1
	)
happyReduction_120 _  = notHappyAtAll 

happyReduce_121 = happySpecReduce_1  63 happyReduction_121
happyReduction_121 (HappyAbsSyn74  happy_var_1)
	 =  HappyAbsSyn63
		 (YExp happy_var_1
	)
happyReduction_121 _  = notHappyAtAll 

happyReduce_122 = happySpecReduce_1  63 happyReduction_122
happyReduction_122 (HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn63
		 (happy_var_1
	)
happyReduction_122 _  = notHappyAtAll 

happyReduce_123 = happySpecReduce_1  63 happyReduction_123
happyReduction_123 (HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn63
		 (happy_var_1
	)
happyReduction_123 _  = notHappyAtAll 

happyReduce_124 = happySpecReduce_1  63 happyReduction_124
happyReduction_124 (HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn63
		 (happy_var_1
	)
happyReduction_124 _  = notHappyAtAll 

happyReduce_125 = happySpecReduce_1  63 happyReduction_125
happyReduction_125 _
	 =  HappyAbsSyn63
		 (YContinue
	)

happyReduce_126 = happySpecReduce_1  63 happyReduction_126
happyReduction_126 _
	 =  HappyAbsSyn63
		 (YBreak
	)

happyReduce_127 = happySpecReduce_1  63 happyReduction_127
happyReduction_127 _
	 =  HappyAbsSyn63
		 (YLeave
	)

happyReduce_128 = happyReduce 5 64 happyReduction_128
happyReduction_128 ((HappyAbsSyn60  happy_var_5) `HappyStk`
	(HappyAbsSyn60  happy_var_4) `HappyStk`
	(HappyAbsSyn74  happy_var_3) `HappyStk`
	(HappyAbsSyn60  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn63
		 (YFor happy_var_2 happy_var_3 happy_var_4 happy_var_5
	) `HappyStk` happyRest

happyReduce_129 = happyReduce 4 65 happyReduction_129
happyReduction_129 ((HappyAbsSyn68  happy_var_4) `HappyStk`
	(HappyAbsSyn66  happy_var_3) `HappyStk`
	(HappyAbsSyn74  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn63
		 (YSwitch happy_var_2 happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_130 = happySpecReduce_2  66 happyReduction_130
happyReduction_130 (HappyAbsSyn66  happy_var_2)
	(HappyAbsSyn67  happy_var_1)
	 =  HappyAbsSyn66
		 (happy_var_1 : happy_var_2
	)
happyReduction_130 _ _  = notHappyAtAll 

happyReduce_131 = happySpecReduce_0  66 happyReduction_131
happyReduction_131  =  HappyAbsSyn66
		 ([]
	)

happyReduce_132 = happySpecReduce_3  67 happyReduction_132
happyReduction_132 (HappyAbsSyn60  happy_var_3)
	(HappyAbsSyn77  happy_var_2)
	_
	 =  HappyAbsSyn67
		 ((happy_var_2, happy_var_3)
	)
happyReduction_132 _ _ _  = notHappyAtAll 

happyReduce_133 = happySpecReduce_2  68 happyReduction_133
happyReduction_133 (HappyAbsSyn60  happy_var_2)
	_
	 =  HappyAbsSyn68
		 (Just happy_var_2
	)
happyReduction_133 _ _  = notHappyAtAll 

happyReduce_134 = happySpecReduce_0  68 happyReduction_134
happyReduction_134  =  HappyAbsSyn68
		 (Nothing
	)

happyReduce_135 = happySpecReduce_3  69 happyReduction_135
happyReduction_135 (HappyAbsSyn60  happy_var_3)
	(HappyAbsSyn74  happy_var_2)
	_
	 =  HappyAbsSyn63
		 (YIf happy_var_2 happy_var_3
	)
happyReduction_135 _ _ _  = notHappyAtAll 

happyReduce_136 = happySpecReduce_3  70 happyReduction_136
happyReduction_136 (HappyAbsSyn71  happy_var_3)
	(HappyAbsSyn58  happy_var_2)
	_
	 =  HappyAbsSyn63
		 (YLet happy_var_2 happy_var_3
	)
happyReduction_136 _ _ _  = notHappyAtAll 

happyReduce_137 = happySpecReduce_2  71 happyReduction_137
happyReduction_137 (HappyAbsSyn74  happy_var_2)
	_
	 =  HappyAbsSyn71
		 (Just happy_var_2
	)
happyReduction_137 _ _  = notHappyAtAll 

happyReduce_138 = happySpecReduce_0  71 happyReduction_138
happyReduction_138  =  HappyAbsSyn71
		 (Nothing
	)

happyReduce_139 = happySpecReduce_3  72 happyReduction_139
happyReduction_139 (HappyAbsSyn74  happy_var_3)
	_
	(HappyAbsSyn58  happy_var_1)
	 =  HappyAbsSyn63
		 (YAssign happy_var_1 happy_var_3
	)
happyReduction_139 _ _ _  = notHappyAtAll 

happyReduce_140 = happySpecReduce_1  73 happyReduction_140
happyReduction_140 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn58
		 ([happy_var_1]
	)
happyReduction_140 _  = notHappyAtAll 

happyReduce_141 = happySpecReduce_3  73 happyReduction_141
happyReduction_141 (HappyAbsSyn58  happy_var_3)
	_
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn58
		 (happy_var_1 : happy_var_3
	)
happyReduction_141 _ _ _  = notHappyAtAll 

happyReduce_142 = happySpecReduce_1  74 happyReduction_142
happyReduction_142 (HappyAbsSyn77  happy_var_1)
	 =  HappyAbsSyn74
		 (YLit happy_var_1
	)
happyReduction_142 _  = notHappyAtAll 

happyReduce_143 = happySpecReduce_1  74 happyReduction_143
happyReduction_143 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn74
		 (YIdent happy_var_1
	)
happyReduction_143 _  = notHappyAtAll 

happyReduce_144 = happySpecReduce_2  74 happyReduction_144
happyReduction_144 (HappyAbsSyn75  happy_var_2)
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn74
		 (YCall happy_var_1 happy_var_2
	)
happyReduction_144 _ _  = notHappyAtAll 

happyReduce_145 = happySpecReduce_3  75 happyReduction_145
happyReduction_145 _
	(HappyAbsSyn75  happy_var_2)
	_
	 =  HappyAbsSyn75
		 (happy_var_2
	)
happyReduction_145 _ _ _  = notHappyAtAll 

happyReduce_146 = happySpecReduce_1  76 happyReduction_146
happyReduction_146 (HappyAbsSyn74  happy_var_1)
	 =  HappyAbsSyn75
		 ([happy_var_1]
	)
happyReduction_146 _  = notHappyAtAll 

happyReduce_147 = happySpecReduce_0  76 happyReduction_147
happyReduction_147  =  HappyAbsSyn75
		 ([]
	)

happyReduce_148 = happySpecReduce_3  76 happyReduction_148
happyReduction_148 (HappyAbsSyn75  happy_var_3)
	_
	(HappyAbsSyn74  happy_var_1)
	 =  HappyAbsSyn75
		 (happy_var_1 : happy_var_3
	)
happyReduction_148 _ _ _  = notHappyAtAll 

happyReduce_149 = happySpecReduce_1  77 happyReduction_149
happyReduction_149 (HappyTerminal (Token _ (TNumber happy_var_1)))
	 =  HappyAbsSyn77
		 (YulNumber $ toInteger happy_var_1
	)
happyReduction_149 _  = notHappyAtAll 

happyReduce_150 = happySpecReduce_1  77 happyReduction_150
happyReduction_150 (HappyTerminal (Token _ (TString happy_var_1)))
	 =  HappyAbsSyn77
		 (YulString happy_var_1
	)
happyReduction_150 _  = notHappyAtAll 

happyReduce_151 = happySpecReduce_1  78 happyReduction_151
happyReduction_151 _
	 =  HappyAbsSyn78
		 (()
	)

happyReduce_152 = happySpecReduce_0  78 happyReduction_152
happyReduction_152  =  HappyAbsSyn78
		 (()
	)

happyNewToken action sts stk
	= lexer(\tk -> 
	let cont i = action i i tk (HappyState action) sts stk in
	case tk of {
	Token _ TEOF -> action 122 122 tk (HappyState action) sts stk;
	Token _ (TIdent happy_dollar_dollar) -> cont 79;
	Token _ (TNumber happy_dollar_dollar) -> cont 80;
	Token _ (TString happy_dollar_dollar) -> cont 81;
	Token _ TContract -> cont 82;
	Token _ TImport -> cont 83;
	Token _ TLet -> cont 84;
	Token _ TEq -> cont 85;
	Token _ TDot -> cont 86;
	Token _ TForall -> cont 87;
	Token _ TClass -> cont 88;
	Token _ TInstance -> cont 89;
	Token _ TIf -> cont 90;
	Token _ TFor -> cont 91;
	Token _ TSwitch -> cont 92;
	Token _ TCase -> cont 93;
	Token _ TDefault -> cont 94;
	Token _ TLeave -> cont 95;
	Token _ TContinue -> cont 96;
	Token _ TBreak -> cont 97;
	Token _ TAssembly -> cont 98;
	Token _ TData -> cont 99;
	Token _ TMatch -> cont 100;
	Token _ TFunction -> cont 101;
	Token _ TConstructor -> cont 102;
	Token _ TReturn -> cont 103;
	Token _ TLam -> cont 104;
	Token _ TType -> cont 105;
	Token _ TNoPattersonCondition -> cont 106;
	Token _ TNoCoverageCondition -> cont 107;
	Token _ TNoBoundVariableCondition -> cont 108;
	Token _ TPragma -> cont 109;
	Token _ TSemi -> cont 110;
	Token _ TYAssign -> cont 111;
	Token _ TColon -> cont 112;
	Token _ TComma -> cont 113;
	Token _ TArrow -> cont 114;
	Token _ TWildCard -> cont 115;
	Token _ TDArrow -> cont 116;
	Token _ TLParen -> cont 117;
	Token _ TRParen -> cont 118;
	Token _ TLBrace -> cont 119;
	Token _ TRBrace -> cont 120;
	Token _ TBar -> cont 121;
	_ -> happyError' (tk, [])
	})

happyError_ explist 122 tk = happyError' (tk, explist)
happyError_ explist _ tk = happyError' (tk, explist)

happyThen :: () => Alex a -> (a -> Alex b) -> Alex b
happyThen = ((>>=))
happyReturn :: () => a -> Alex a
happyReturn = (return)
happyThen1 :: () => Alex a -> (a -> Alex b) -> Alex b
happyThen1 = happyThen
happyReturn1 :: () => a -> Alex a
happyReturn1 = happyReturn
happyError' :: () => ((Token), [Prelude.String]) -> Alex a
happyError' tk = (\(tokens, _) -> parseError tokens) tk
parser = happySomeParser where
 happySomeParser = happyThen (happyParse action_0) (\x -> case x of {HappyAbsSyn4 z -> happyReturn z; _other -> notHappyAtAll })

happySeq = happyDontSeq


parseError (Token (line, col) lexeme)
  = alexError $ "Parse error while processing lexeme: " ++ show lexeme
                ++ "\n at line " ++ show line ++ ", column " ++ show col

lexer :: (Token -> Alex a) -> Alex a
lexer = (=<< alexMonadScan)
{-# LINE 1 "templates/GenericTemplate.hs" #-}
-- $Id: GenericTemplate.hs,v 1.26 2005/01/14 14:47:22 simonmar Exp $










































data Happy_IntList = HappyCons Prelude.Int Happy_IntList








































infixr 9 `HappyStk`
data HappyStk a = HappyStk a (HappyStk a)

-----------------------------------------------------------------------------
-- starting the parse

happyParse start_state = happyNewToken start_state notHappyAtAll notHappyAtAll

-----------------------------------------------------------------------------
-- Accepting the parse

-- If the current token is ERROR_TOK, it means we've just accepted a partial
-- parse (a %partial parser).  We must ignore the saved token on the top of
-- the stack in this case.
happyAccept (1) tk st sts (_ `HappyStk` ans `HappyStk` _) =
        happyReturn1 ans
happyAccept j tk st sts (HappyStk ans _) = 
         (happyReturn1 ans)

-----------------------------------------------------------------------------
-- Arrays only: do the next action









































indexShortOffAddr arr off = arr Happy_Data_Array.! off


{-# INLINE happyLt #-}
happyLt x y = (x Prelude.< y)






readArrayBit arr bit =
    Bits.testBit (indexShortOffAddr arr (bit `Prelude.div` 16)) (bit `Prelude.mod` 16)






-----------------------------------------------------------------------------
-- HappyState data type (not arrays)



newtype HappyState b c = HappyState
        (Prelude.Int ->                    -- token number
         Prelude.Int ->                    -- token number (yes, again)
         b ->                           -- token semantic value
         HappyState b c ->              -- current state
         [HappyState b c] ->            -- state stack
         c)



-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state (1) tk st sts stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--     trace "shifting the error token" $
     new_state i i tk (HappyState (new_state)) ((st):(sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state ((st):(sts)) ((HappyTerminal (tk))`HappyStk`stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_0 nt fn j tk st@((HappyState (action))) sts stk
     = action nt j tk st ((st):(sts)) (fn `HappyStk` stk)

happySpecReduce_1 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@(((st@(HappyState (action))):(_))) (v1`HappyStk`stk')
     = let r = fn v1 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_2 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_2 nt fn j tk _ ((_):(sts@(((st@(HappyState (action))):(_))))) (v1`HappyStk`v2`HappyStk`stk')
     = let r = fn v1 v2 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_3 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_3 nt fn j tk _ ((_):(((_):(sts@(((st@(HappyState (action))):(_))))))) (v1`HappyStk`v2`HappyStk`v3`HappyStk`stk')
     = let r = fn v1 v2 v3 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happyReduce k i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyReduce k nt fn j tk st sts stk
     = case happyDrop (k Prelude.- ((1) :: Prelude.Int)) sts of
         sts1@(((st1@(HappyState (action))):(_))) ->
                let r = fn stk in  -- it doesn't hurt to always seq here...
                happyDoSeq r (action nt j tk st1 sts1 r)

happyMonadReduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
          let drop_stk = happyDropStk k stk in
          happyThen1 (fn stk tk) (\r -> action nt j tk st1 sts1 (r `HappyStk` drop_stk))

happyMonad2Reduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonad2Reduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
         let drop_stk = happyDropStk k stk





             _ = nt :: Prelude.Int
             new_state = action

          in
          happyThen1 (fn stk tk) (\r -> happyNewToken new_state sts1 (r `HappyStk` drop_stk))

happyDrop (0) l = l
happyDrop n ((_):(t)) = happyDrop (n Prelude.- ((1) :: Prelude.Int)) t

happyDropStk (0) l = l
happyDropStk n (x `HappyStk` xs) = happyDropStk (n Prelude.- ((1)::Prelude.Int)) xs

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction









happyGoto action j tk st = action j j tk (HappyState action)


-----------------------------------------------------------------------------
-- Error recovery (ERROR_TOK is the error token)

-- parse error if we are in recovery and we fail again
happyFail explist (1) tk old_st _ stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--      trace "failing" $ 
        happyError_ explist i tk

{-  We don't need state discarding for our restricted implementation of
    "error".  In fact, it can cause some bogus parses, so I've disabled it
    for now --SDM

-- discard a state
happyFail  ERROR_TOK tk old_st CONS(HAPPYSTATE(action),sts) 
                                                (saved_tok `HappyStk` _ `HappyStk` stk) =
--      trace ("discarding state, depth " ++ show (length stk))  $
        DO_ACTION(action,ERROR_TOK,tk,sts,(saved_tok`HappyStk`stk))
-}

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail explist i tk (HappyState (action)) sts stk =
--      trace "entering error recovery" $
        action (1) (1) tk (HappyState (action)) sts ((HappyErrorToken (i)) `HappyStk` stk)

-- Internal happy errors:

notHappyAtAll :: a
notHappyAtAll = Prelude.error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions







-----------------------------------------------------------------------------
-- Seq-ing.  If the --strict flag is given, then Happy emits 
--      happySeq = happyDoSeq
-- otherwise it emits
--      happySeq = happyDontSeq

happyDoSeq, happyDontSeq :: a -> b -> b
happyDoSeq   a b = a `Prelude.seq` b
happyDontSeq a b = b

-----------------------------------------------------------------------------
-- Don't inline any functions from the template.  GHC has a nasty habit
-- of deciding to inline happyGoto everywhere, which increases the size of
-- the generated parser quite a bit.









{-# NOINLINE happyShift #-}
{-# NOINLINE happySpecReduce_0 #-}
{-# NOINLINE happySpecReduce_1 #-}
{-# NOINLINE happySpecReduce_2 #-}
{-# NOINLINE happySpecReduce_3 #-}
{-# NOINLINE happyReduce #-}
{-# NOINLINE happyMonadReduce #-}
{-# NOINLINE happyGoto #-}
{-# NOINLINE happyFail #-}

-- end of Happy Template.
