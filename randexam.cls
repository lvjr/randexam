% -*- coding: utf-8 -*-
% ----------------------------------------------------------------------------
% Author:  Jianrui Lyu <tolvjr@163.com>
% License: The LaTeX Project Public License 1.3c
% ----------------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{randexam}[2024-01-17 v2024A Make an exam and its randomized variants]

%% 旧版本的 LaTeX 不能识别 2022-11-01 这种日期格式
%\@ifl@t@r\fmtversion{2022-11-01}{}{
\@ifl@t@r\fmtversion{2022/11/01}{}{
  \ClassError{randexam}{%
    Your current TeX distribution is quite old.\MessageBreak
    We need CTeX 3.0+ or MiKTeX 2023+ or TeXLive 2023+%
  }{Please update your TeX distribution first.}
}

\RequirePackage{etoolbox}

\newif\ifplain       \plainfalse      % 是否添加装订线和草稿纸
\newif\iftwoinone    \twoinonefalse   % 是否使用 A3 纸张
\newif\ifoneside     \onesidefalse    % 是否单面印刷试卷
\newif\ifresetnumber \resetnumbertrue % 是否对各题型小题分别编号
\newif\ifrandom      \randomfalse     % 是否乱序出题
\newif\ifanswer      \answertrue      % 是否显示答案
\newif\ifamsfonts    \amsfontsfalse   % 切换数学字体
\newif\iffreealign   \freealignfalse  % load freealign package
\newif\ifcellspace   \cellspacefalse  % 增加表格列间距
\newif\ifmedmath     \medmathfalse    % 切换公式尺寸
\newif\ifgrader      \graderfalse     % add grader line in the grade table

\DeclareOption{plain}{\plaintrue}
\DeclareOption{a3paper}{\twoinonetrue}
\DeclareOption{a3input}{\twoinonetrue\plaintrue}
\DeclareOption{oneside}{\onesidetrue}
\DeclareOption{random}{\randomtrue}
\DeclareOption{noanswer}{\answerfalse}
\DeclareOption{amsfonts}{\amsfontstrue}
\DeclareOption{freealign}{\freealigntrue}
\DeclareOption{medmath}{\cellspacetrue\medmathtrue}
\DeclareOption{grader}{\gradertrue}

\DeclareOption{many}{%
  \booltrue{freealign}%
}

\DeclareOption{most}{%
  \booltrue{freealign}%
  \booltrue{medmath}%
  \booltrue{cellspace}%
}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}} % other options

\ProcessOptions\relax

\LoadClass{article}

\iftwoinone
  \RequirePackage[a3paper,landscape,twocolumn,columnsep=60mm,left=30mm,right=30mm,top=25mm,bottom=25mm]{geometry}
\else
  \RequirePackage[a4paper,left=30mm,right=30mm,top=25mm,bottom=25mm]{geometry}
\fi

\RequirePackage{amsmath}
\RequirePackage{array}
\RequirePackage{calc}
\RequirePackage{comment}
\RequirePackage[inline]{enumitem}
\RequirePackage{environ}
\RequirePackage{fancyhdr}
\RequirePackage{zref-user,zref-lastpage}
\RequirePackage{tabularx}
\RequirePackage{xcolor}
\RequirePackage{xkeyval}

\ifplain
  \allowdisplaybreaks[4]
\fi

\ifamsfonts
  \RequirePackage{amssymb}
\else
  \RequirePackage[utopia]{mathdesign} % charter, utopia
  \renewcommand\bfdefault{bx}
  \let\oldoiint\oiint\renewcommand{\oiint}{\oldoiint\nolimits}
  \DeclareTextCommandDefault{\nobreakspace}{\leavevmode\nobreak\ }
\fi

\newcolumntype{Y}{>{\centering\arraybackslash}X}
\newcolumntype{n}[1]{>{\centering\arraybackslash}m{#1}}

\setlength{\parindent}{0em}
\setlength{\lineskiplimit}{4pt}
\setlength{\lineskip}{4pt}

\newcommand{\setexam}[1]{\setkeys{exam@setup}{#1}}

%% ---------------------------------------------------------------------------
%% 试卷表头命令 \makehead
%% ---------------------------------------------------------------------------

\newcommand{\underspace}[1]{\kern0pt\underline{\hspace{#1}}\kern0pt\relax}
\newcommand{\underbox}[2]{\kern0pt\underline{\makebox[#1]{#2}}\kern0pt\relax}
\newcommand{\underparbox}[2]{\kern0pt\underline{\parbox[b]{#1}{#2}}\kern0pt\relax}

\newcommand{\ischeck}[1]{\ifnum#1>0\,$\checkmark$\,\else\quad\fi}
\newcommand{\isquad}[1]{\ifnum#1=0\,$\checkmark$\,\else\quad\fi}

\newcommand\my@temp@a{A}
\newcommand\my@temp@c{C}
\newcommand\my@empty{}

\newcommand{\examtitle}{Math 1906}
\newcommand{\examdate}{\today}
\newcommand{\examvariant}{A}

\newcommand\makehead{
  \thispagestyle{plain}
  \ifbool{random}{%
    \ifx\examvariant\my@temp@a\renewcommand{\examvariant}{B}\fi
    \ifx\examvariant\my@temp@c\renewcommand{\examvariant}{D}\fi
  }{}%
  \begingroup
  \Large\noindent
  \ifbool{answer}{%
    \textcolor{red!80!black}{\examtitle\hfill Solutions}%
  }{%
    \examtitle\hfill Name:\underspace{6em}%
  }\par
  \endgroup
}

%% ---------------------------------------------------------------------------
%% Command for grade table: \gradetable
%% ---------------------------------------------------------------------------

\let\exam@part@number=\Roman
\define@key{exam@setup}{partnumber}[\Roman]{\let\exam@part@number=#1}

\newcounter{@exam@grade@cnt}
\newcommand\my@part@number[1]{%
  \stepcounter{@exam@grade@cnt}%
  \exam@part@number{@exam@grade@cnt}%
}

\newcommand\insertpartname{Part}
\newcommand\insertscorename{Score}
\newcommand\insertgradername{Grader}
\newcommand\inserttotalname{Total}

\newcommand\gradetable{%
  \par\vspace{1em}%
  \setcounter{@exam@grade@cnt}{0}%
  \noindent\begin{tabularx}{\linewidth}{|*{8}{Y|}}
    \hline
    \textbf{\insertpartname}
      & \my@part@number{1} & \my@part@number{2} & \my@part@number{3}
      & \my@part@number{4} & \my@part@number{5} & \my@part@number{6}
      & \inserttotalname\\
    \hline
    \textbf{\insertscorename}\rule[-0.75em]{0pt}{2.5em} &  &  &  &  &  &  & \\
    \hline
    \ifbool{grader}{
      \textbf{\insertgradername}\rule[-0.75em]{0pt}{2.5em} &  &  &  &  &  &  & \\
      \hline
    }{}
  \end{tabularx}
}

%% ---------------------------------------------------------------------------
%% 页眉页脚设定
%% ---------------------------------------------------------------------------

\newcommand{\my@columnbox}[1]{\makebox[\columnwidth]{#1}}
\newcommand{\my@headleft}{\examtitle}
\newcommand{\my@headright}{\ifbool{answer}{Solutions}{Name:\hspace{12em}}}
\newcommand{\my@headtext}{\my@headleft\hfill\my@headright}
\newcommand{\my@footleft}{\examdate}
\newcommand{\my@footcenter}{Page~\thepage~of~\zpageref{LastPage}}
\newcommand{\my@footright}{Version \examvariant}
\newcommand{\my@foottext}{\my@footleft\hfill\my@footcenter\hfill\my@footright}

% fancy page style
\fancyhf{} % clear head and foot
\iftwoinone
  \renewcommand{\headrulewidth}{0pt}%
  \lhead{\small\underline{\my@columnbox{\my@headtext}\strut}}
  \rhead{\small\underline{\my@columnbox{\my@headtext}\strut}}
  \lfoot{\small\my@columnbox{\my@foottext}}
  \rfoot{\small\my@columnbox{\stepcounter{page}\my@foottext}}
\else
  \lhead{\small\my@headleft}
  \rhead{\small\my@headright}
  \cfoot{\small\my@foottext}
\fi

% plain page style
\fancypagestyle{plain}{
  \renewcommand{\headrulewidth}{0pt}%
  \fancyhf{}
  \iftwoinone
    \rhead{\small\underline{\my@columnbox{\my@headtext\strut}}}
    \lfoot{\small\my@columnbox{\my@foottext}}
    \rfoot{\small\my@columnbox{\stepcounter{page}\my@foottext}}
  \else
    \cfoot{\small\my@foottext}
  \fi
}

\ifplain
  \pagestyle{plain}
\else
  \pagestyle{fancy}
\fi

%% ---------------------------------------------------------------------------
%% 乱序排列选项 random
%% 随机种子选项 seed
%% ---------------------------------------------------------------------------

%% 随机数种子不能超过 2147483647 = "7FFFFFFF
\def\my@random@seed{19061116}
\define@key{exam@setup}{seed}[19061116]{\def\my@random@seed{#1}}

\ifrandom
  \RequirePackage{pgf}
  \RequirePackage{pgffor}
  \newcommand*\exam@set@seed{%
    %% 当\pgfmathrandom的参数为3的倍数时，对相邻种子生成的多个随机数分布不均匀
    %\pgfmathsetseed{\numexpr\my@random@seed+\value{section}-1\relax}%
    %% 因此我们改用下面的方法，用随机数种子生成下一个随机数种子
    \pgfmathsetseed{\my@random@seed}%
    \pgfmathrandominteger\my@random@seed{1}{2147483647}%
  }
\fi

%% ---------------------------------------------------------------------------
%% 题型命令 \makepart
%% 附录命令 \makedata
%% 题目环境 problem
%% 解答环境 solution
%% ---------------------------------------------------------------------------

\newif\ifonlyoneproblem \onlyoneproblemfalse % 此部分仅有一道题时不显示题目编号
\xdef\allproblems{}
\xdef\lastproblem{}
\newcounter{problem}        % 当前题型的小题编号
\newcounter{problemreal}    % 实际显示的小题编号，在各题型小题统一编号时使用
\newcounter{totalproblems}  % 之前各题型小题总数，在各题型小题统一编号时使用
\newcommand{\solutionname}{Solution}
\newcounter{choice} % 后面选择题的 abcd 环境要用到
\newcommand{\hangtext}{}
\newlength{\hanglength}
\colorlet{part number}{black}
\colorlet{problem number}{blue!80!black}
\colorlet{solution name}{blue!80!black}

\newcounter{my@shuffle@temp@cnt}
\newcounter{my@list@temp@cnt}

\newcommand\my@list@print[1]{%
  \par\renewcommand*{\do}[1]{(##1)}%
  \dolistloop#1%
}

\newcommand\my@list@remove[2]{%
  %\my@list@print\my@shuffle@list
  \setcounter{my@list@temp@cnt}{0}%
  \global\let\my@tmpa@list=#1%
  \gdef#1{}%
  \par\renewcommand*{\do}[1]{%
    \stepcounter{my@list@temp@cnt}%
    \ifnumequal{\value{my@list@temp@cnt}}{#2}{%
      \def\my@list@item{##1}%
      %[##1]%
    }{
      \listxadd#1{##1}%
    }%
  }%
  \dolistloop\my@tmpa@list
}

\newcommand\my@shuffle@problems{%
  \exam@set@seed
  \ifnumgreater{\value{problem}}{2}{%
    \gdef\my@shuffle@list{}%
    \foreach \i in {1,...,\value{problem}} {\listxadd\my@shuffle@list{\i}}%
    %% 首尾两个小题的位置总要改变
    \pgfmathrandom{2,\value{problem}}%
    \my@list@remove\my@shuffle@list{\pgfmathresult}%
    \global\csletcs{my@problem@b@1}{my@problem@a@\my@list@item}%
    \ifnumequal{\my@list@item}{\value{problem}}{
      \pgfmathrandom{\numexpr\value{problem}-1\relax}%
      \my@list@remove\my@shuffle@list{\pgfmathresult}%
      \global\csletcs{my@problem@b@\the\value{problem}}{my@problem@a@\my@list@item}%
    }{%
      \pgfmathrandom{\numexpr\value{problem}-2\relax}%
      \my@list@remove\my@shuffle@list{\pgfmathresult}%
      \global\csletcs{my@problem@b@\the\value{problem}}{my@problem@a@\my@list@item}%
    }%
    %% 其他小题的位置没有任何限制
    \setcounter{my@shuffle@temp@cnt}{1}%
    \whileboolexpr{%
      test{\ifnumless{\value{my@shuffle@temp@cnt}}{\numexpr\value{problem}-1\relax}}%
    }{%
      \stepcounter{my@shuffle@temp@cnt}%
      \pgfmathrandom{\numexpr\value{problem}-\value{my@shuffle@temp@cnt}\relax}%
      \my@list@remove\my@shuffle@list{\pgfmathresult}%
      \global\csletcs{my@problem@b@\the\value{my@shuffle@temp@cnt}}{%
        my@problem@a@\my@list@item
      }%
    }%
  }{%
    \ifnumequal{\value{problem}}{2}{%
      \global\csletcs{my@problem@b@1}{my@problem@a@2}%
      \global\csletcs{my@problem@b@2}{my@problem@a@1}%
    }{}%
  }%
}

\newcommand{\printproblems}{%
  \ifrandom
    \my@appto@problems
    \my@shuffle@problems
    \setcounter{problem}{0}%
    \allproblems
  \fi
  \xdef\allproblems{}%
  \xdef\lastproblem{}%
}

\newcommand\insertpart[2]{%
  \noindent\textbf{\textcolor{part number}{Part~\Roman{section}}: #1} (#2)%
}

\newcommand{\makepart}[2]{%
  \printproblems
  \setcounter{totalproblems}{\value{totalproblems}+\value{problem}}%
  \setcounter{problem}{0}%
  \stepcounter{section}%
  \vspace{1em}%
  \insertpart{#1}{#2}%
  \par\nopagebreak
  \if\relax\detokenize{#1}\relax % #1 is empty
    \onlyoneproblemtrue
  \else
    \onlyoneproblemfalse
    \vspace{1em}%
  \fi
  %其中设定了\@nobreaktrue，保证在列表前也不分页，详情见 source2e
  \@afterheading
}

\renewcommand\appendixname{Appendix}
\newcommand{\makedata}[1]{%
  \printproblems\my@stop@random
  \centerline{\textbf{\appendixname}\quad #1}\smallskip
}

\preto{\@enddocumenthook}{\printproblems\my@stop@random}

\newcommand\ignorepars{\@ifnextchar\par{\expandafter\ignorepars\@gobble}{}}

% 局部定义，仅在当前题目内有效
\define@key{exam@problem}{points}[-1]{\def\my@problem@points{#1}}
\define@key{exam@problem}{level}[]{\def\my@problem@level{#1}}
\define@key{exam@problem}{year}[]{\def\my@problem@year{#1}}

\newcommand\pointname{point}
\newcommand\pointsname{points}
\newcommand\pointorpoints[1]{\ifnumgreater{#1}{1}{\pointsname}{\pointname}}

\newcommand{\problempointstext}[1]{ (#1 \pointorpoints{#1}) }

\newcommand\my@hook@exec@other@keys{}

\newcommand{\execute@problem@keys}[1]{%
  \setkeys{exam@problem}{#1}%
  \my@hook@exec@other@keys
  \ifdefvoid{\my@problem@points}{}{\problempointstext{\my@problem@points}}%
}

\newenvironment{problemreal}[1][]{%
  \stepcounter{problem}\setcounter{choice}{0}%
  \ifresetnumber
    \ifonlyoneproblem
      \renewcommand{\hangtext}{\qquad}%
    \else
      \renewcommand{\hangtext}{\textbf{\textsf{\textcolor{problem number}{\arabic{problem}}.}}\;\,}%
    \fi
  \else
    \setcounter{problemreal}{\value{totalproblems}+\value{problem}}%
    \renewcommand{\hangtext}{\textbf{\textsf{\textcolor{problem number}{\arabic{problemreal}}.}}\;\,}%
  \fi
  \settowidth{\hanglength}{\hangtext}%
  \description[leftmargin=\hanglength,labelwidth=0pt,labelsep=0pt,topsep=0pt,parsep=0pt]
  \item[\hangtext]\execute@problem@keys{#1}%
}{\enddescription}
\newenvironment{solutionreal}{%
  \renewcommand{\hangtext}{\textbf{\textsf{\textcolor{solution name}{\solutionname}.}}\;\,}%
  \settowidth{\hanglength}{\hangtext}%
  \description[leftmargin=\hanglength,labelwidth=0pt,labelsep=0pt,topsep=0pt,parsep=0pt]
  \item[\hangtext]
}{\enddescription}

\let \oldnewpage   = \newpage
\let \oldvfill     = \vfill
\let \oldsmallskip = \smallskip
\let \oldmedskip   = \medskip
\let \oldbigskip   = \bigskip

\ifrandom
  \newcommand\my@appto@problems{%
    \xappto\allproblems{\expandonce\lastproblem}%
  }%
  \NewEnviron{problem}{%
    \stepcounter{problem}%
    \my@appto@problems
    \csxdef{my@problem@a@\the\value{problem}}{%
      \unexpanded{\begin{problemreal}}%
      \unexpanded\expandafter{\BODY}%
      \unexpanded{\end{problemreal}}%
    }%
    \csxdef{my@problem@b@\the\value{problem}}{%
      \expandonce{\csname my@problem@a@\the\value{problem}\endcsname}%
    }%
    \xdef\lastproblem{%
      \expandonce{\csname my@problem@b@\the\value{problem}\endcsname}%
    }%
  }
  \NewEnviron{solution}{%
    \csxappto{my@problem@a@\the\value{problem}}{%
      \unexpanded{\begin{solutionreal}}%
      \expandonce{\BODY}%
      \unexpanded{\end{solutionreal}}%
    }%
  }
  \renewcommand{\newpage}{\gappto\lastproblem{\oldnewpage}}
  \renewcommand{\vfill}{\csgappto{my@problem@a@\the\value{problem}}{\oldvfill}}
  \renewcommand{\smallskip}{\csgappto{my@problem@a@\the\value{problem}}{\oldsmallskip}}
  \renewcommand{\medskip}{\csgappto{my@problem@a@\the\value{problem}}{\oldmedskip}}
  \renewcommand{\bigskip}{\csgappto{my@problem@a@\the\value{problem}}{\oldbigskip}}
\else
  \newenvironment{problem}[1][]{\problemreal[#1]}{\endproblemreal}
  %\newenvironment{solution}{\solutionreal}{\endsolutionreal}
  \NewEnviron{solution}{\begin{solutionreal}\BODY\end{solutionreal}}
\fi

\newcommand{\my@stop@random}{%
  \ifrandom
    \renewenvironment{problem}{\problemreal}{\endproblemreal}%
    \renewenvironment{solution}{\solutionreal}{\endsolutionreal}%
    \let \newpage   = \oldnewpage
    \let \vfill     = \oldvfill
    \let \smallskip = \oldsmallskip
    \let \medskip   = \oldmedskip
    \let \bigskip   = \oldbigskip
  \fi
}

\def\CommentCutFile{\jobname.cut}

\AtBeginDocument{%
  \ifanswer\else
    \excludecomment{solution}
  \fi
}

%% ---------------------------------------------------------------------------
%% 答题栏命令 \answertable
%% ---------------------------------------------------------------------------

\gdef\answer@lines@temp{}%
\newcommand{\answer@lines@add}[1]{%
  \xdef\answer@lines@temp{\answer@lines@temp#1}%
}

\newcommand\insertnumbertext{Number}
\newcommand\insertanswertext{Answer}
\newcommand\insertanswertabletext{%
  Notice: you MUST write the answers in the following tables.%
}

\newrobustcmd{\answer@number@hided}[1]{\insertnumbertext} % 在 PDFLaTeX 中需要保护中文
\newrobustcmd{\answer@cell@strut}[1]{\parbox[c][#1][c]{2em}{\hbox{\insertanswertext}}}

\newcounter{answer@col}
\newcounter{answer@row}
\newcounter{answer@total}

\newcommand{\answer@lines}[3]{%
  % #1 答题栏各栏指定高度
  % #2 答题栏总共答案个数
  % #3 答题栏每行答案个数
  \setcounter{answer@row}{(#2-1)/#3+1}% 除法向下取整，改为向上取整
  \begingroup
  \let\hline=\relax  \let\\=\relax % 禁止展开
  \gdef\answer@lines@temp{}%
  \setcounter{answer@total}{1}%
  \whileboolexpr{
      test{\ifnumgreater{\value{answer@row}}{0}}
  }{%
      \addtocounter{answer@row}{-1}%
      \answer@lines@add{\answer@number@hided}%
      \setcounter{answer@col}{1}%
      \unlessboolexpr{%
          test{\ifnumgreater{\value{answer@col}}{#3}}%
      }{%
          \answer@lines@add{&}%
          \ifnumgreater{\value{answer@total}}{#2}{}{%
            \answer@lines@add{\arabic{answer@total}}%
          }%
          \stepcounter{answer@col}%
          \stepcounter{answer@total}%
      }%
      \answer@lines@add{\\ \hline \answer@cell@strut{#1}}%
      \setcounter{answer@col}{1}%
      \unlessboolexpr{
          test{\ifnumgreater{\value{answer@col}}{#3}}
      }{%
          \answer@lines@add{&}%
          \stepcounter{answer@col}%
      }%
      \answer@lines@add{\\ \hline}%
  }%
  \endgroup
  \answer@lines@temp
}

\newcommand{\answertable}[3][1em]{%
  \insertanswertabletext\par
  \begin{tabularx}{\linewidth}{|c|*{#3}{Y|}}
    \hline
    \answer@lines{#1}{#2}{#3}
  \end{tabularx}%
  \par\vspace{0.8em}%
}

%% ---------------------------------------------------------------------------
%% 答案切换命令 \answer
%% 判断命令 \tickin 和 \tickout
%% 填空命令 \fillin 和 \fillout
%% 选择命令 \pickin 和 \pickout
%% ---------------------------------------------------------------------------

\newcommand{\answer}[1]{\ifanswer#1\else\phantom{#1}\fi}

\newcommand*{\cdotfill}{\leavevmode\xleaders\hbox to 0.5em{\hss$\cdot$\hss}\hfill\kern0pt\relax}

\newcommand*{\tick@box}[1]{[\makebox[1.5em]{\color{blue}\answer{#1}}]}
\newcommand*{\tick@text@t}{$\checkmark$}
\newcommand*{\tick@text@f}{{\large$\times$}}
\newcommand*{\tick@text@T}{\sffamily T}
\newcommand*{\tick@text@F}{\sffamily F}
\newcommand*{\tickin}[1]{\tick@box{\csname tick@text@#1\endcsname}}
\newcommand*{\tickout}[1]{\unskip\nobreak\cdotfill\tick@box{\csname tick@text@#1\endcsname}}

\newcommand*{\ulinefill}[1]{\xleaders\hbox{\underline{\vphantom{#1}\kern1pt}}\hfill\kern0pt}
\newcommand*{\minwidthbox}[2]{\makebox[{\ifdim#1<\width\width\else#1\fi}]{#2}}

\newcommand*{\fillout}[1]{\allowbreak\hbox{}\nobreak\ulinefill{#1}\underline{\color{blue}\answer{#1}}\ulinefill{#1}}
\newcommand*{\fillin}[1]{\underline{\hspace{1em}\color{blue}\minwidthbox{2em}{\answer{#1}}\hspace{1em}}}

\newcommand*\pickoutreal[1]{%
  \unskip\nobreak\cdotfill(\makebox[1.5em]{\color{blue}\answer{#1}})%
}
\newcommand*\pickinreal[1]{%
  \unskip\nobreak
  \hspace{0.3em}(\makebox[1.5em]{\color{blue}\answer{#1}})\hspace{0.3em}%
  \ignorespaces
}

%% 选择题四个选项打乱顺序，用三种方法即可保证答案不同
%% 1：ABCD -> CDAB； 2：ABCD -> BADC; 3: ABCD -> DCBA
%% 即在两行排列时仅用到上下交换以及左右交换，这样可以保持两行长度不变

\csdef{my@shuffle@1@A}{C} \csdef{my@shuffle@2@A}{B} \csdef{my@shuffle@3@A}{D}
\csdef{my@shuffle@1@B}{D} \csdef{my@shuffle@2@B}{A} \csdef{my@shuffle@3@B}{C}
\csdef{my@shuffle@1@C}{A} \csdef{my@shuffle@2@C}{D} \csdef{my@shuffle@3@C}{B}
\csdef{my@shuffle@1@D}{B} \csdef{my@shuffle@2@D}{C} \csdef{my@shuffle@3@D}{A}

\def\@my@choice@random{0}
\newcommand\my@shuffle@abcd[1]{\csuse{my@shuffle@\@my@choice@random @#1}}

\newcommand*\pickout[1]{%
  \ifbool{random}{%
    \exam@set@seed
    \pgfmathrandominteger\@my@choice@random{1}{3}%
    %\@my@choice@random
    \pickoutreal{\my@shuffle@abcd{#1}}%
  }{%
    \pickoutreal{#1}%
  }%
}
\newcommand*\pickoutfixed[1]{%
  \pickoutreal{#1}%
  \randomfalse
}
\newcommand*\pickin[1]{%
  \ifbool{random}{%
    \exam@set@seed
    \pgfmathrandominteger\@my@choice@random{1}{3}%
    %\@my@choice@random
    \pickinreal{\my@shuffle@abcd{#1}}%
  }{%
    \pickinreal{#1}%
  }%
}
\newcommand*\pickinfixed[1]{%
  \pickinreal{#1}%
  \randomfalse
}

%% ---------------------------------------------------------------------------
%% 选择题四个选项排版环境，根据四个选项的长度自动排成一行、两行或四行
%% 其中 abcd 环境各列平分整行宽度，而 abcd* 环境各列平分剩余空白
%% ---------------------------------------------------------------------------

\newlength{\my@item@len}
\newlength{\my@label@len}

\newcommand\my@item@temp{%
  \unskip\cr\stepcounter{choice}(\Alph{choice})\ %
}
\newcommand\my@item@box{%
  \hfill\egroup\hfill\hbox to \my@item@len\bgroup
  \stepcounter{choice}(\Alph{choice})\ \ignorespaces
}
\newcommand\my@item@par{%
  \stepcounter{choice}%
  \def\my@label@text{(\Alph{choice})\ }%
  \settowidth{\my@label@len}{\my@label@text}%
  \par \parshape 2 \hanglength \linewidth
  \dimexpr\hanglength + \my@label@len\relax
  \dimexpr\linewidth - \my@label@len\relax
  \my@label@text\ignorespaces
}

\NewEnviron{abcdreal}{
  \unskip
  \setlength{\parindent}{0pt}%
  \setlength{\parskip}{0pt}%
  \setcounter{choice}{0}%
  \let\item=\my@item@temp
  \settowidth{\my@item@len}{\vbox{\halign{##\hfil\cr\BODY\crcr}}}%
  \setcounter{choice}{0}%
  \ifdim\my@item@len>0.486\linewidth
    \setlength{\my@item@len}{\linewidth}%
    \let\item=\my@item@par
    \BODY\par
  \else
    \ifdim\my@item@len>.243\linewidth
      \setlength{\my@item@len}{0.5\linewidth}%
    \else
      \setlength{\my@item@len}{0.25\linewidth}%
    \fi
    \let\item=\my@item@box
    \par\bgroup\BODY\hfill\egroup\par
  \fi
}

\newcommand\my@item@one@line{%
  \unskip
  \ifnumequal{\value{choice}}{0}{}{\hfill}
  \stepcounter{choice}(\Alph{choice})\ %
}
\newcommand\my@item@two@line{%
  \unskip
  \ifnumodd{\value{choice}}{&}{\unskip\cr}%
  \stepcounter{choice}(\Alph{choice})\ %
}

\NewEnviron{abcd*real}{
  \unskip
  \setlength{\parindent}{0pt}%
  \setlength{\parskip}{0pt}%
  \setcounter{choice}{0}%
  \let\item=\my@item@one@line
  \settowidth{\my@item@len}{\BODY}%
  \ifdim\my@item@len<0.95\linewidth
    \setcounter{choice}{0}%
    \par\bgroup\BODY\hfill\hfill\par\egroup\par
  \else
    \setcounter{choice}{0}%
    \let\item=\my@item@two@line
    \settowidth{\my@item@len}{\vbox{\halign{##&##\hfil\cr\BODY\crcr}}}%
    \ifdim\my@item@len<0.975\linewidth
      \setcounter{choice}{0}%
      \par\bgroup\nointerlineskip
      \vbox{\halign to\linewidth{##\hfil\tabskip=0pt plus 1fil&##\hfil\cr\BODY\crcr}}%
      \egroup\par
    \else
      \setcounter{choice}{0}%
      \let\item=\my@item@par
      \par\bgroup\BODY\hfill\egroup\par
    \fi
  \fi
}

\ifbool{random}{%
  \csdef{my@swap@items@1}#1#2#3#4{\item#3\item#4\item#1\item#2}
  \csdef{my@swap@items@2}#1#2#3#4{\item#2\item#1\item#4\item#3}
  \csdef{my@swap@items@3}#1#2#3#4{\item#4\item#3\item#2\item#1}
  \long\def\my@swap@items#1\item#2\item#3\item#4\item#5\@my@stop@mark{%
    #1\csuse{my@swap@items@\@my@choice@random}{#2}{#3}{#4}{#5}%
  }
}{}

\NewDocumentEnvironment{abcd}{+b}{%
  \ifbool{random}{%
    \begin{abcdreal}\my@swap@items#1\@my@stop@mark\end{abcdreal}%
  }{%
    \begin{abcdreal}#1\end{abcdreal}%
  }%
}{}
\NewDocumentEnvironment{abcd*}{+b}{%
  \ifbool{random}{%
    \begin{abcd*real}\my@swap@items#1\@my@stop@mark\end{abcd*real}%
  }{%
    \begin{abcd*real}#1\end{abcd*real}%
  }%
}{}

%% ---------------------------------------------------------------------------
%% 设定有序列表使用悬挂缩进，并指定前两级有序列表的标签格式
%% 标签宽度按最宽者自动设定，左边距自动计算，竖直空白全部去掉
%% 最后的 itemjoin 设定行内有序列表 enumerate* 两项之间的空白
%% ---------------------------------------------------------------------------

\setlist[enumerate]{labelindent=0pt,labelsep=0.2em,itemindent=0pt,leftmargin=*,nosep,itemjoin=\quad}
\setlist[enumerate,1]{label=(\arabic*)}
\setlist[enumerate,2]{label=(\alph*),widest*=1}

%% ---------------------------------------------------------------------------
%% 自由对齐命令 \tabpoint, \tabto, \tableft
%% 命令 \tabpoint 记录当前的水平位置，也可以简写为 \?
%% 命令 \tabto 跳到之前记录的位置，也可以简写为 \+
%% 命令 \tableft 跳到之前记录的位置的左侧，也可以简写为 \<
%% 这些自由对齐命令需要编译两次才能生效
%% ---------------------------------------------------------------------------

\AtBeginDocument{%
  \ifbool{freealign}{\RequirePackage{freealign}}{}%
}

%% ---------------------------------------------------------------------------
%% 评分命令 \points
%% ---------------------------------------------------------------------------

\PassOptionsToPackage{tbtags}{amsmath}
\RequirePackage{amsmath}

\newcommand{\solutionpointstext}[1]{%
  \textcolor{red}{#1\kern0.15em\pointorpoints{#1}}%
}

\newcommand{\pointstext}[1]{%
  \mbox{}\nobreak\hfill$\cdots\cdots$\solutionpointstext{#1}%
  \par\noindent\ignorespaces
}
\newcommand{\pointseqno}[1]{\eqno{\cdots\cdots\text{\solutionpointstext{#1}}}}
\newcommand{\pointstag}[1]{\tag*{$\cdots\cdots$\solutionpointstext{#1}}}

\newrobustcmd{\points}[1]{%
  \ifbool{mmode}{%
    \ifdefstrequal{\tag}{\dft@tag}{\pointseqno{#1}}{\pointstag{#1}}%
  }{%
    \pointstext{#1}%
  }%
}

%% ---------------------------------------------------------------------------
%% 统一行间公式和行内公式的巨算符和分式的尺寸
%% 利用开头的 medmath 选项可以启用此部分设定
%% ---------------------------------------------------------------------------

\AtBeginDocument{%
  \ifbool{medmath}{\RequirePackage{medmath}}{}%
}

%% ---------------------------------------------------------------------------
%% 在 tabular 和 array 等表格环境中添加列间距
%% 避免单元格里出现的分式太过接近上面和下面行
%% ---------------------------------------------------------------------------

\newcommand{\my@do@cellspace}{%
  \RequirePackage[math]{cellspace}%
  \setlength\cellspacetoplimit{2pt}%
  \setlength\cellspacebottomlimit{2pt}%
  \addparagraphcolumntypes{X}%
  \newcolumntype{0}[1]{>{\bcolumn ##1\@nil}##1<{\ecolumn}}%
  \newcolumntype{5}[1]{>{$}0{##1}<{$}}%
  % Fix cellspace bug before version 1.7
  % See https://tex.stackexchange.com/a/385581
  \@ifpackagelater{cellspace}{2017/08/12}{}{%
    \patchcmd{\@endpbox}{\color@endgroup}{\expandafter\color@endgroup}{}{}%
  }%
  %% redefine cases environment fixed by medmath
  \renewenvironment{cases}{%
    \left\{\linespread{1.0}\selectfont\def\arraystretch{1.2}%
    \begin{array}{@{}5l@{}>{\quad}5l@{}}%
  }{%
    \end{array}\right.%
  }%
}

\AtBeginDocument{%
  \ifcellspace \my@do@cellspace \fi
}

%% ---------------------------------------------------------------------------
%% 载入常用宏包，定义常用命令
%% ---------------------------------------------------------------------------

\AtBeginDocument{
  \setlength{\abovedisplayskip}{4pt minus 2pt}
  \setlength{\belowdisplayskip}{4pt minus 2pt}
  \setlength{\abovedisplayshortskip}{2pt}
  \setlength{\belowdisplayshortskip}{2pt}
}

\setlength\arraycolsep{4pt}

\RequirePackage{multirow}
\RequirePackage{tabu}

\RequirePackage{diagbox}
%% 修正 \diagbox 在 array 环境中使用的问题
\newrobustcmd{\diagboxtwo}[3][]{%
  \ifbool{mmode}{%
    \hbox{\let\tabcolsep=\arraycolsep\diagbox[#1]{$#2$}{$#3$}}%
  }{%
    \diagbox[#1]{#2}{#3}%
  }
}
\newrobustcmd{\diagboxthree}[4][]{%
  \ifbool{mmode}{%
    \hbox{\let\tabcolsep=\arraycolsep\diagbox[#1]{$#2$}{$#3$}{$#4$}}%
  }{%
    \diagbox[#1]{#2}{#3}{#4}%
  }
}

\RequirePackage{mathtools} % \mathllap 命令，pmatrix* 环境等
\RequirePackage{extarrows}

\RequirePackage{relsize}
\newcommand{\Int}{\mathop{\mathlarger{\int}}}

\AtBeginDocument{%
  \let\my@saved@lim=\lim    \def\lim{\my@saved@lim\limits}%
  \let\my@saved@sum=\sum    \def\sum{\my@saved@sum\limits}%
  \let\my@saved@prod=\prod  \def\prod{\my@saved@prod\limits}%
}

\newcommand{\e}{\mathrm{e}}
\newcommand{\R}{\mathbb{R}}

\DeclareMathOperator{\arccot}{arccot}
\DeclareMathOperator{\Corr}{\rho}
\DeclareMathOperator{\Cov}{Cov}
\DeclareMathOperator{\diag}{diag}
\DeclareMathOperator{\grad}{grad}
\DeclareMathOperator{\Prj}{Prj}
\DeclareMathOperator{\tr}{tr}
\DeclareMathOperator{\Var}{Var}

\DeclareMathOperator{\diver}{div}
\let\division=\div
\let\div=\diver

\newcommand{\diff}{\mathop{}\!\mathrm{d}}
\newcommand{\dx}{\diff x}
\newcommand{\dy}{\diff y}
\def\dz{\diff z} % 不确定命令是否已经定义
\newcommand{\du}{\diff u}
\newcommand{\dv}{\diff v}
\newcommand{\dr}{\diff r}
\newcommand{\ds}{\diff s}
\newcommand{\dt}{\diff t}
\newcommand{\dS}{\diff S}
% 有些宏包比如 hyperref 会修改 \d 的定义，所以放在 document 开始处
% 利用 etoolbox 将 \d 定义为健壮命令，以避免在 align 等环境中错误地展开
\AtBeginDocument{%
  \let\oldd=\d
  \renewrobustcmd{\d}{\ifbool{mmode}{\diff}{\oldd}}%
}

\let\pd=\partial
\newcommand{\pdf}{\pd f}
\newcommand{\pdg}{\pd g}
\newcommand{\pdh}{\pd h}
\newcommand{\pdl}{\pd l}
\newcommand{\pdn}{\pd n}
\newcommand{\pdu}{\pd u}
\newcommand{\pdv}{\pd v}
\newcommand{\pdx}{\pd x}
\newcommand{\pdy}{\pd y}
\newcommand{\pdz}{\pd z}
\newcommand{\pdF}{\pd F}
\newcommand{\pdL}{\pd L}
\newcommand{\pdP}{\pd P}
\newcommand{\pdQ}{\pd Q}
\newcommand{\pdR}{\pd R}

% from mathabx package
\DeclareFontFamily{U}{mathx}{\hyphenchar\font45}
\DeclareFontShape{U}{mathx}{m}{n}{<-> mathx10}{}
\DeclareSymbolFont{mathx}{U}{mathx}{m}{n}
\DeclareMathAccent{\widebar}{0}{mathx}{"73}

\newcommand{\va}{\vec{a}}
\newcommand{\vb}{\vec{b}}
\newcommand{\vc}{\vec{c}}
\newcommand{\vd}{\vec{d}}
\newcommand{\ve}{\vec{e}}
\newcommand{\vi}{\vec{i}}
\newcommand{\vj}{\vec{j}}
\newcommand{\vk}{\vec{k}}
\newcommand{\vn}{\vec{n}}
\newcommand{\vs}{\vec{s}}
\newcommand{\vv}{\vec{v}}

\let\ov=\overrightarrow

\let\le=\leqslant
\let\ge=\geqslant

\let\lb=\{
\let\rb=\}

\def\T{\mathrm{T}\kern-.5pt}

% 分数线长一点的分数，\wfrac[2pt]{x}{y} 表示左右加 2pt
% 和前面的 medmath 一样，将代码放在 \AtBeginDocument 里
\AtBeginDocument{%
  \newrobustcmd{\wfrac}[3][2pt]{%
    \frac{\hspace{#1}#2\hspace{#1}}{\hspace{#1}#3\hspace{#1}}%
  }%
  \newrobustcmd{\wdfrac}[3][2pt]{%
    \dfrac{\hspace{#1}#2\hspace{#1}}{\hspace{#1}#3\hspace{#1}}%
  }%
  \newrobustcmd{\wtfrac}[3][2pt]{%
    \tfrac{\hspace{#1}#2\hspace{#1}}{\hspace{#1}#3\hspace{#1}}%
  }%
}

% 使用 stix font 中的 white arrows
\AtBeginDocument{\@ifpackageloaded{fontspec}{%
    %\IfFileExists{STIX-Regular.otf}{% 在 TeXLive 中无效
    \IfFileExists{stix.sty}{%
        \newfontfamily{\mystix}{STIX} % stix v1.1
    }{%
        \newfontfamily{\mystix}{STIXGeneral} % stix v1.0
    }
    \newrobustcmd\leftwhitearrow{%
      \mathrel{\text{\normalfont\mystix\symbol{"21E6}}}%
    }
    \newrobustcmd\upwhitearrow{%
      \mathrel{\text{\normalfont\mystix\symbol{"21E7}}}%
    }
    \newrobustcmd\rightwhitearrow{%
      \mathrel{\text{\normalfont\mystix\symbol{"21E8}}}%
    }
    \newrobustcmd\downwhitearrow{%
      \mathrel{\text{\normalfont\mystix\symbol{"21E9}}}%
    }
}{%
    \let \leftwhitearrow = \Leftarrow
    \let \rightwhitearrow = \Rightarrow
    \let \upwhitearrow = \Uparrow
    \let \downwhitearrow = \Downarrow
}}

