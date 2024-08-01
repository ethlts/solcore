module Language.Yul.Parser(parseYul, yulBlock) where
{-
import Text.Megaparsec
import Text.Megaparsec.Char
import Data.Void
-}
import Common.LightYear
import Text.Megaparsec.Char.Lexer qualified as L
import Language.Yul


parseYul :: String -> Yul
parseYul = runMyParser "yul" yulProgram

sc :: Parser ()
sc = L.space space1
             (L.skipLineComment "//")
             (L.skipBlockComment "/*" "*/")

lexeme :: Parser a -> Parser a
lexeme = L.lexeme sc

symbol :: String -> Parser String
symbol = L.symbol sc

startIdentChar :: Parser Char
startIdentChar = letterChar <|> char '_' <|> char '$'

identChar :: Parser Char
identChar = alphaNumChar <|> char '_' <|> char '$'

identifier :: Parser String
identifier = lexeme ((:) <$> startIdentChar <*> many identChar)

integer :: Parser Integer
integer = lexeme L.decimal

stringLiteral :: Parser String
stringLiteral = char '"' *> manyTill L.charLiteral (char '"')

parens :: Parser a -> Parser a
parens = between (symbol "(") (symbol ")")

commaSep :: Parser a -> Parser [a]
commaSep p = p `sepBy` symbol ","

pKeyword :: String -> Parser String
pKeyword w = lexeme (string w <* notFollowedBy identChar)

yulExpression :: Parser YulExpression
yulExpression = choice
    [ YulLiteral <$> yulLiteral
    , try (YulCall <$> identifier <*> parens (commaSep yulExpression))
    , YulIdentifier <$> identifier
    ]

yulLiteral :: Parser YulLiteral
yulLiteral = choice
    [ YulNumber <$> integer
    , YulString <$> stringLiteral
    , YulTrue <$ pKeyword "true"
    , YulFalse <$ pKeyword "false"
    ]

yulStmt :: Parser YulStmt
yulStmt = choice
    [ YulBlock <$> yulBlock
    , yulFun
    , YulLet <$> (pKeyword "let" *> commaSep identifier) <*> optional (symbol ":=" *> yulExpression)
    , YulIf <$> (pKeyword "if" *> yulExpression) <*> yulBlock
    , YulSwitch <$>
        (pKeyword "switch" *> yulExpression) <*>
        many yulCase <*>
        optional (pKeyword "default" *> yulBlock)
    , try (YulAssign <$> commaSep identifier <*> (symbol ":=" *> yulExpression))
    , YulExpression <$> yulExpression
    ]

yulBlock :: Parser [YulStmt]
yulBlock = between (symbol "{") (symbol "}") (many yulStmt)

yulCase :: Parser (YulLiteral, [YulStmt])
yulCase = do
    _ <- pKeyword "case"
    lit <- yulLiteral
    stmts <- yulBlock
    return (lit, stmts)

yulFun :: Parser YulStmt
yulFun = do
    _ <- symbol "function"
    name <- identifier
    args <- parens (commaSep identifier)
    rets <- optional (symbol "->" *> (commaSep identifier))
    stmts <- yulBlock
    return (YulFun name args rets stmts)

yulProgram :: Parser Yul
yulProgram = sc *> (Yul <$> many yulStmt) <* eof
