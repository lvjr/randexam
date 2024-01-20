% -*- coding: utf-8 -*-
% ----------------------------------------------------------------------------
% Author:  Jianrui Lyu <tolvjr@163.com>
% License: The LaTeX Project Public License 1.3c
% ----------------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{randexam}[2024-01-20 v2024B Make an exam paper and its randomized variants]

%% Old LaTeX release could not recongnize date format like 2022-11-01
%\@ifl@t@r\fmtversion{2022-11-01}{}{
\@ifl@t@r\fmtversion{2022/11/01}{}{
  \ClassError{randexam}{%
    Your current TeX distribution is quite old.\MessageBreak
    We need CTeX 3.0+ or MiKTeX 2023+ or TeXLive 2023+%
  }{Please update your TeX distribution first.}
}

\RequirePackage{etoolbox}

\newbool{plain}       \boolfalse{plain}      % use plain page style
\newbool{twoinone}    \boolfalse{twoinone}   % use A3 paper
\newbool{oneside}     \boolfalse{oneside}    % use single sided exam paper
\newbool{resetnumber} \booltrue{resetnumber} % reset numbers in new exam groups
\newbool{random}      \boolfalse{random}     % shuffle questions
\newbool{answer}      \booltrue{answer}      % show answers
\newbool{amsfonts}    \boolfalse{amsfonts}   % use ams fonts
\newbool{freealign}   \boolfalse{freealign}  % load freealign package
\newbool{medmath}     \boolfalse{medmath}    % use medium-size formulas
\newbool{grader}      \boolfalse{grader}     % add grader line in the grade table

\DeclareKeys{
  plain     .if    = plain,
  a3paper   .if    = twoinone,
  a3input   .code  = \booltrue{twoinone}\booltrue{plain},
  oneside   .if    = oneside,
  random    .if    = random,
  noanswer  .ifnot = answer,
  amsfonts  .if    = amsfonts,
  freealign .if    = freealign,
  medmath   .if    = medmath,
  grader    .if    = grader,
  many      .code  = \booltrue{freealign},
  most      .code  = \booltrue{freealign}\booltrue{medmath}
}

\DeclareUnknownKeyHandler{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessKeyOptions

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

\NewDocumentCommand\SetExamOption{+m}{\SetKeys[randexam]{#1}}

%% ---------------------------------------------------------------------------
%% Command for exam title: \examtitle
%% ---------------------------------------------------------------------------

\newcommand{\underspace}[1]{\kern0pt\underline{\hspace{#1}}\kern0pt\relax}
\newcommand{\underbox}[2]{\kern0pt\underline{\makebox[#1]{#2}}\kern0pt\relax}
\newcommand{\underparbox}[2]{\kern0pt\underline{\parbox[b]{#1}{#2}}\kern0pt\relax}

\newcommand{\ischeck}[1]{\ifnum#1>0\,$\checkmark$\,\else\quad\fi}
\newcommand{\isquad}[1]{\ifnum#1=0\,$\checkmark$\,\else\quad\fi}

\def\rdxm@temp@a{A}
\def\rdxm@temp@c{C}
\def\rdxm@empty{}

\DeclareKeys[randexam-title]{
  name    .store = \@rdxm@title@name,
  date    .store = \@rdxm@title@date,
  version .store = \@rdxm@title@version
}

\NewDocumentCommand\SetExamTitle{+m}{\SetKeys[randexam-title]{#1}}

\SetExamTitle{name=Math 1906,date=\today,version=A}

\newcommand\examtitle[1]{%
  \SetExamTitle{#1}%
  \thispagestyle{plain}
  \ifbool{random}{%
    \ifx\@rdxm@title@version\rdxm@temp@a\def\@rdxm@title@version{B}\fi
    \ifx\@rdxm@title@version\rdxm@temp@c\def\@rdxm@title@version{D}\fi
  }{}%
  \begingroup
  \Large\noindent
  \ifbool{answer}{%
    \textcolor{red!80!black}{\@rdxm@title@name\hfill Solutions}%
  }{%
    \@rdxm@title@name\hfill Name:\underspace{6em}%
  }\par
  \endgroup
}

%% ---------------------------------------------------------------------------
%% Command for grade table: \gradetable
%% ---------------------------------------------------------------------------

%% You need to put .code:n before .initial:n
\DeclareKeys[randexam]{%
  groupnumber .code:n    = \let\exam@group@number#1,
  groupnumber .initial:n = \Roman,
}

\newcounter{@exam@grade@cnt}
\newcommand\rdxm@group@number[1]{%
  \stepcounter{@exam@grade@cnt}%
  \exam@group@number{@exam@grade@cnt}%
}

\newcommand\insertgroupname{Part}
\newcommand\insertscorename{Score}
\newcommand\insertgradername{Grader}
\newcommand\inserttotalname{Total}

\newcommand\gradetable{%
  \par\vspace{1em}%
  \setcounter{@exam@grade@cnt}{0}%
  \noindent\begin{tabularx}{\linewidth}{|*{8}{Y|}}
    \hline
    \textbf{\insertgroupname}
      & \rdxm@group@number{1} & \rdxm@group@number{2} & \rdxm@group@number{3}
      & \rdxm@group@number{4} & \rdxm@group@number{5} & \rdxm@group@number{6}
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
%% Setting header and footer
%% ---------------------------------------------------------------------------

\newcommand{\rdxm@columnbox}[1]{\makebox[\columnwidth]{#1}}
\newcommand{\rdxm@headleft}{\@rdxm@title@name}
\newcommand{\rdxm@headright}{\ifbool{answer}{Solutions}{Name:\hspace{12em}}}
\newcommand{\rdxm@headtext}{\rdxm@headleft\hfill\rdxm@headright}
\newcommand{\rdxm@footleft}{\@rdxm@title@date}
\newcommand{\rdxm@footcenter}{Page~\thepage~of~\zpageref{LastPage}}
\newcommand{\rdxm@footright}{Version \@rdxm@title@version}
\newcommand{\rdxm@foottext}{\rdxm@footleft\hfill\rdxm@footcenter\hfill\rdxm@footright}

% fancy page style
\fancyhf{} % clear head and foot
\iftwoinone
  \renewcommand{\headrulewidth}{0pt}%
  \lhead{\small\underline{\rdxm@columnbox{\rdxm@headtext}\strut}}
  \rhead{\small\underline{\rdxm@columnbox{\rdxm@headtext}\strut}}
  \lfoot{\small\rdxm@columnbox{\rdxm@foottext}}
  \rfoot{\small\rdxm@columnbox{\stepcounter{page}\rdxm@foottext}}
\else
  \lhead{\small\rdxm@headleft}
  \rhead{\small\rdxm@headright}
  \cfoot{\small\rdxm@foottext}
\fi

% plain page style
\fancypagestyle{plain}{
  \renewcommand{\headrulewidth}{0pt}%
  \fancyhf{}
  \iftwoinone
    \rhead{\small\underline{\rdxm@columnbox{\rdxm@headtext\strut}}}
    \lfoot{\small\rdxm@columnbox{\rdxm@foottext}}
    \rfoot{\small\rdxm@columnbox{\stepcounter{page}\rdxm@foottext}}
  \else
    \cfoot{\small\rdxm@foottext}
  \fi
}

\ifplain
  \pagestyle{plain}
\else
  \pagestyle{fancy}
\fi

%% ---------------------------------------------------------------------------
%% Class option for shuffling questions: random
%% Class option for random seed: seed
%% ---------------------------------------------------------------------------

%% The random seed could not exceed 2147483647 = "7FFFFFFF
%% You need to put .store before .initial:n
\DeclareKeys[randexam]{
  seed .store     = \rdxm@random@seed,
  seed .initial:n = 19061116
}

\ifrandom
  \RequirePackage{pgf}
  \RequirePackage{pgffor}
  \newcommand*\exam@set@seed{%
    %% 当\pgfmathrandom的参数为3的倍数时，对相邻种子生成的多个随机数分布不均匀
    %\pgfmathsetseed{\numexpr\rdxm@random@seed+\value{rdxm@group}-1\relax}%
    %% 因此我们改用下面的方法，用随机数种子生成下一个随机数种子
    \pgfmathsetseed{\rdxm@random@seed}%
    \pgfmathrandominteger\rdxm@random@seed{1}{2147483647}%
  }
\fi

%% ---------------------------------------------------------------------------
%% Command for exam groups: \examgroup
%% Command for appendix data: \examdata
%% Environment for questions: question
%% Environment for solutions: solution
%% ---------------------------------------------------------------------------

\newif\ifonlyonequestion \onlyonequestionfalse % 此部分仅有一道题时不显示题目编号
\xdef\allquestions{}
\xdef\lastquestion{}
\newcounter{question}        % 当前题型的小题编号
\newcounter{questionreal}    % 实际显示的小题编号，在各题型小题统一编号时使用
\newcounter{totalquestions}  % 之前各题型小题总数，在各题型小题统一编号时使用
\newcommand{\solutionname}{Solution}
\newcounter{choice} % 后面选择题的 abcd 环境要用到
\newcommand{\hangtext}{}
\newlength{\hanglength}
\colorlet{group number}{black}
\colorlet{question number}{blue!80!black}
\colorlet{solution name}{blue!80!black}

\newcounter{rdxm@shuffle@temp@cnt}
\newcounter{rdxm@list@temp@cnt}

\newcommand\rdxm@list@print[1]{%
  \par\renewcommand*{\do}[1]{(##1)}%
  \dolistloop#1%
}

\newcommand\rdxm@list@remove[2]{%
  %\rdxm@list@print\rdxm@shuffle@list
  \setcounter{rdxm@list@temp@cnt}{0}%
  \global\let\rdxm@tmpa@list=#1%
  \gdef#1{}%
  \par\renewcommand*{\do}[1]{%
    \stepcounter{rdxm@list@temp@cnt}%
    \ifnumequal{\value{rdxm@list@temp@cnt}}{#2}{%
      \def\rdxm@list@item{##1}%
      %[##1]%
    }{
      \listxadd#1{##1}%
    }%
  }%
  \dolistloop\rdxm@tmpa@list
}

\newcommand\rdxm@shuffle@questions{%
  \exam@set@seed
  \ifnumgreater{\value{question}}{2}{%
    \gdef\rdxm@shuffle@list{}%
    \foreach \i in {1,...,\value{question}} {\listxadd\rdxm@shuffle@list{\i}}%
    %% 首尾两个小题的位置总要改变
    \pgfmathrandom{2,\value{question}}%
    \rdxm@list@remove\rdxm@shuffle@list{\pgfmathresult}%
    \global\csletcs{rdxm@question@b@1}{rdxm@question@a@\rdxm@list@item}%
    \ifnumequal{\rdxm@list@item}{\value{question}}{
      \pgfmathrandom{\numexpr\value{question}-1\relax}%
      \rdxm@list@remove\rdxm@shuffle@list{\pgfmathresult}%
      \global\csletcs{rdxm@question@b@\the\value{question}}{rdxm@question@a@\rdxm@list@item}%
    }{%
      \pgfmathrandom{\numexpr\value{question}-2\relax}%
      \rdxm@list@remove\rdxm@shuffle@list{\pgfmathresult}%
      \global\csletcs{rdxm@question@b@\the\value{question}}{rdxm@question@a@\rdxm@list@item}%
    }%
    %% 其他小题的位置没有任何限制
    \setcounter{rdxm@shuffle@temp@cnt}{1}%
    \whileboolexpr{%
      test{\ifnumless{\value{rdxm@shuffle@temp@cnt}}{\numexpr\value{question}-1\relax}}%
    }{%
      \stepcounter{rdxm@shuffle@temp@cnt}%
      \pgfmathrandom{\numexpr\value{question}-\value{rdxm@shuffle@temp@cnt}\relax}%
      \rdxm@list@remove\rdxm@shuffle@list{\pgfmathresult}%
      \global\csletcs{rdxm@question@b@\the\value{rdxm@shuffle@temp@cnt}}{%
        rdxm@question@a@\rdxm@list@item
      }%
    }%
  }{%
    \ifnumequal{\value{question}}{2}{%
      \global\csletcs{rdxm@question@b@1}{rdxm@question@a@2}%
      \global\csletcs{rdxm@question@b@2}{rdxm@question@a@1}%
    }{}%
  }%
}

\newcommand{\printquestions}{%
  \ifrandom
    \rdxm@appto@questions
    \rdxm@shuffle@questions
    \setcounter{question}{0}%
    \allquestions
  \fi
  \xdef\allquestions{}%
  \xdef\lastquestion{}%
}

\newcounter{rdxm@group}

\newcommand\insertgroup[2]{%
  \noindent\textbf{\textcolor{group number}{Part~\Roman{rdxm@group}}: #1} (#2)%
}

\newcommand{\examgroup}[2]{%
  \printquestions
  \setcounter{totalquestions}{\value{totalquestions}+\value{question}}%
  \setcounter{question}{0}%
  \stepcounter{rdxm@group}%
  \vspace{1em}%
  \insertgroup{#1}{#2}%
  \par\nopagebreak
  \if\relax\detokenize{#1}\relax % #1 is empty
    \onlyonequestiontrue
  \else
    \onlyonequestionfalse
    \vspace{1em}%
  \fi
  %其中设定了\@nobreaktrue，保证在列表前也不分页，详情见 source2e
  \@afterheading
}

\renewcommand\appendixname{Appendix}
\newcommand{\examdata}[1]{%
  \printquestions\rdxm@stop@random
  \centerline{\textbf{\appendixname}\quad #1}\smallskip
}

\preto{\@enddocumenthook}{\printquestions\rdxm@stop@random}

\newcommand\ignorepars{\@ifnextchar\par{\expandafter\ignorepars\@gobble}{}}

% 局部定义，仅在当前题目内有效
\define@key{exam@question}{points}[-1]{\def\rdxm@question@points{#1}}
\define@key{exam@question}{level}[]{\def\rdxm@question@level{#1}}
\define@key{exam@question}{year}[]{\def\rdxm@question@year{#1}}

\newcommand\pointname{point}
\newcommand\pointsname{points}
\newcommand\pointorpoints[1]{\ifnumgreater{#1}{1}{\pointsname}{\pointname}}

\newcommand{\questionpointstext}[1]{ (#1 \pointorpoints{#1}) }

\newcommand\rdxm@hook@exec@other@keys{}

\newcommand{\execute@question@keys}[1]{%
  \setkeys{exam@question}{#1}%
  \rdxm@hook@exec@other@keys
  \ifdefvoid{\rdxm@question@points}{}{\questionpointstext{\rdxm@question@points}}%
}

\newenvironment{questionreal}[1][]{%
  \stepcounter{question}\setcounter{choice}{0}%
  \ifresetnumber
    \ifonlyonequestion
      \renewcommand{\hangtext}{\qquad}%
    \else
      \renewcommand{\hangtext}{\textbf{\textsf{\textcolor{question number}{\arabic{question}}.}}\;\,}%
    \fi
  \else
    \setcounter{questionreal}{\value{totalquestions}+\value{question}}%
    \renewcommand{\hangtext}{\textbf{\textsf{\textcolor{question number}{\arabic{questionreal}}.}}\;\,}%
  \fi
  \settowidth{\hanglength}{\hangtext}%
  \description[leftmargin=\hanglength,labelwidth=0pt,labelsep=0pt,topsep=0pt,parsep=0pt]
  \item[\hangtext]\execute@question@keys{#1}%
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
  \newcommand\rdxm@appto@questions{%
    \xappto\allquestions{\expandonce\lastquestion}%
  }%
  \NewEnviron{question}{%
    \stepcounter{question}%
    \rdxm@appto@questions
    \csxdef{rdxm@question@a@\the\value{question}}{%
      \unexpanded{\begin{questionreal}}%
      \unexpanded\expandafter{\BODY}%
      \unexpanded{\end{questionreal}}%
    }%
    \csxdef{rdxm@question@b@\the\value{question}}{%
      \expandonce{\csname rdxm@question@a@\the\value{question}\endcsname}%
    }%
    \xdef\lastquestion{%
      \expandonce{\csname rdxm@question@b@\the\value{question}\endcsname}%
    }%
  }
  \NewEnviron{solution}{%
    \csxappto{rdxm@question@a@\the\value{question}}{%
      \unexpanded{\begin{solutionreal}}%
      \expandonce{\BODY}%
      \unexpanded{\end{solutionreal}}%
    }%
  }
  \renewcommand{\newpage}{\gappto\lastquestion{\oldnewpage}}
  \renewcommand{\vfill}{\csgappto{rdxm@question@a@\the\value{question}}{\oldvfill}}
  \renewcommand{\smallskip}{\csgappto{rdxm@question@a@\the\value{question}}{\oldsmallskip}}
  \renewcommand{\medskip}{\csgappto{rdxm@question@a@\the\value{question}}{\oldmedskip}}
  \renewcommand{\bigskip}{\csgappto{rdxm@question@a@\the\value{question}}{\oldbigskip}}
\else
  \newenvironment{question}[1][]{\questionreal[#1]}{\endquestionreal}
  %\newenvironment{solution}{\solutionreal}{\endsolutionreal}
  \NewEnviron{solution}{\begin{solutionreal}\BODY\end{solutionreal}}
\fi

\newcommand{\rdxm@stop@random}{%
  \ifrandom
    \renewenvironment{question}{\questionreal}{\endquestionreal}%
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
%% Command for answer tables: \answertable
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
%% Command for toggling answers: \answer
%% Command for true-or-false questions: \tickin and \tickout
%% Command for fill-in-the-blank questions: \fillin and \fillout
%% Command for multiple-choice questions: \pickin and \pickout
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

\csdef{rdxm@shuffle@1@A}{C} \csdef{rdxm@shuffle@2@A}{B} \csdef{rdxm@shuffle@3@A}{D}
\csdef{rdxm@shuffle@1@B}{D} \csdef{rdxm@shuffle@2@B}{A} \csdef{rdxm@shuffle@3@B}{C}
\csdef{rdxm@shuffle@1@C}{A} \csdef{rdxm@shuffle@2@C}{D} \csdef{rdxm@shuffle@3@C}{B}
\csdef{rdxm@shuffle@1@D}{B} \csdef{rdxm@shuffle@2@D}{C} \csdef{rdxm@shuffle@3@D}{A}

\def\@rdxm@choice@random{0}
\newcommand\rdxm@shuffle@abcd[1]{\csuse{rdxm@shuffle@\@rdxm@choice@random @#1}}

\newcommand*\pickout[1]{%
  \ifbool{random}{%
    \exam@set@seed
    \pgfmathrandominteger\@rdxm@choice@random{1}{3}%
    %\@rdxm@choice@random
    \pickoutreal{\rdxm@shuffle@abcd{#1}}%
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
    \pgfmathrandominteger\@rdxm@choice@random{1}{3}%
    %\@rdxm@choice@random
    \pickinreal{\rdxm@shuffle@abcd{#1}}%
  }{%
    \pickinreal{#1}%
  }%
}
\newcommand*\pickinfixed[1]{%
  \pickinreal{#1}%
  \randomfalse
}

%% ---------------------------------------------------------------------------
%% Environment abcd for typesetting options of multiple-choice questions
%% Put them in one, two, or four rows according to the lengths of the choices
%% ---------------------------------------------------------------------------

\newlength{\rdxm@item@len}
\newlength{\rdxm@label@len}

\newcommand\rdxm@item@temp{%
  \unskip\cr\stepcounter{choice}(\Alph{choice})\ %
}
\newcommand\rdxm@item@box{%
  \hfill\egroup\hfill\hbox to \rdxm@item@len\bgroup
  \stepcounter{choice}(\Alph{choice})\ \ignorespaces
}
\newcommand\rdxm@item@par{%
  \stepcounter{choice}%
  \def\rdxm@label@text{(\Alph{choice})\ }%
  \settowidth{\rdxm@label@len}{\rdxm@label@text}%
  \par \parshape 2 \hanglength \linewidth
  \dimexpr\hanglength + \rdxm@label@len\relax
  \dimexpr\linewidth - \rdxm@label@len\relax
  \rdxm@label@text\ignorespaces
}

\NewEnviron{abcdreal}{
  \unskip
  \setlength{\parindent}{0pt}%
  \setlength{\parskip}{0pt}%
  \setcounter{choice}{0}%
  \let\item=\rdxm@item@temp
  \settowidth{\rdxm@item@len}{\vbox{\halign{##\hfil\cr\BODY\crcr}}}%
  \setcounter{choice}{0}%
  \ifdim\rdxm@item@len>0.486\linewidth
    \setlength{\rdxm@item@len}{\linewidth}%
    \let\item=\rdxm@item@par
    \BODY\par
  \else
    \ifdim\rdxm@item@len>.243\linewidth
      \setlength{\rdxm@item@len}{0.5\linewidth}%
    \else
      \setlength{\rdxm@item@len}{0.25\linewidth}%
    \fi
    \let\item=\rdxm@item@box
    \par\bgroup\BODY\hfill\egroup\par
  \fi
}

\newcommand\rdxm@item@one@line{%
  \unskip
  \ifnumequal{\value{choice}}{0}{}{\hfill}
  \stepcounter{choice}(\Alph{choice})\ %
}
\newcommand\rdxm@item@two@line{%
  \unskip
  \ifnumodd{\value{choice}}{&}{\unskip\cr}%
  \stepcounter{choice}(\Alph{choice})\ %
}

\NewEnviron{abcd*real}{
  \unskip
  \setlength{\parindent}{0pt}%
  \setlength{\parskip}{0pt}%
  \setcounter{choice}{0}%
  \let\item=\rdxm@item@one@line
  \settowidth{\rdxm@item@len}{\BODY}%
  \ifdim\rdxm@item@len<0.95\linewidth
    \setcounter{choice}{0}%
    \par\bgroup\BODY\hfill\hfill\par\egroup\par
  \else
    \setcounter{choice}{0}%
    \let\item=\rdxm@item@two@line
    \settowidth{\rdxm@item@len}{\vbox{\halign{##&##\hfil\cr\BODY\crcr}}}%
    \ifdim\rdxm@item@len<0.975\linewidth
      \setcounter{choice}{0}%
      \par\bgroup\nointerlineskip
      \vbox{\halign to\linewidth{##\hfil\tabskip=0pt plus 1fil&##\hfil\cr\BODY\crcr}}%
      \egroup\par
    \else
      \setcounter{choice}{0}%
      \let\item=\rdxm@item@par
      \par\bgroup\BODY\hfill\egroup\par
    \fi
  \fi
}

\ifbool{random}{%
  \csdef{rdxm@swap@items@1}#1#2#3#4{\item#3\item#4\item#1\item#2}
  \csdef{rdxm@swap@items@2}#1#2#3#4{\item#2\item#1\item#4\item#3}
  \csdef{rdxm@swap@items@3}#1#2#3#4{\item#4\item#3\item#2\item#1}
  \long\def\rdxm@swap@items#1\item#2\item#3\item#4\item#5\@rdxm@stop@mark{%
    #1\csuse{rdxm@swap@items@\@rdxm@choice@random}{#2}{#3}{#4}{#5}%
  }
}{}

\NewDocumentEnvironment{abcd}{+b}{%
  \ifbool{random}{%
    \begin{abcdreal}\rdxm@swap@items#1\@rdxm@stop@mark\end{abcdreal}%
  }{%
    \begin{abcdreal}#1\end{abcdreal}%
  }%
}{}
\NewDocumentEnvironment{abcd*}{+b}{%
  \ifbool{random}{%
    \begin{abcd*real}\rdxm@swap@items#1\@rdxm@stop@mark\end{abcd*real}%
  }{%
    \begin{abcd*real}#1\end{abcd*real}%
  }%
}{}

%% ---------------------------------------------------------------------------
%% Use hangindent in enumerate lists, and remove extra vertical space
%% The itemjoin set space between items in inline enumerate* environment
%% ---------------------------------------------------------------------------

\setlist[enumerate]{labelindent=0pt,labelsep=0.2em,itemindent=0pt,leftmargin=*,nosep,itemjoin=\quad}
\setlist[enumerate,1]{label=(\arabic*)}
\setlist[enumerate,2]{label=(\alph*),widest*=1}

%% ---------------------------------------------------------------------------
%% Use freealign package to align math formulas in different lines
%% ---------------------------------------------------------------------------

\AtBeginDocument{%
  \ifbool{freealign}{\RequirePackage{freealign}}{}%
}

%% ---------------------------------------------------------------------------
%% Command for giving points in solutions: \points
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
%% Use medium-size fractions and operators in both inline and displayed formulas
%% ---------------------------------------------------------------------------

\AtBeginDocument{%
  \ifbool{medmath}{\RequirePackage{medmath}}{}%
}

%% ---------------------------------------------------------------------------
%% Load more packages, define more commands
%% ---------------------------------------------------------------------------

\AtBeginDocument{
  \setlength{\abovedisplayskip}{4pt minus 2pt}
  \setlength{\belowdisplayskip}{4pt minus 2pt}
  \setlength{\abovedisplayshortskip}{2pt}
  \setlength{\belowdisplayshortskip}{2pt}
}

\setlength\arraycolsep{4pt}

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

\AtBeginDocument{%
  \let\rdxm@saved@lim=\lim    \def\lim{\rdxm@saved@lim\limits}%
  \let\rdxm@saved@sum=\sum    \def\sum{\rdxm@saved@sum\limits}%
  \let\rdxm@saved@prod=\prod  \def\prod{\rdxm@saved@prod\limits}%
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
        \newfontfamily{\@rdxm@stix}{STIX} % stix v1.1
    }{%
        \newfontfamily{\@rdxm@stix}{STIXGeneral} % stix v1.0
    }
    \newrobustcmd\leftwhitearrow{%
      \mathrel{\text{\normalfont\@rdxm@stix\symbol{"21E6}}}%
    }
    \newrobustcmd\upwhitearrow{%
      \mathrel{\text{\normalfont\@rdxm@stix\symbol{"21E7}}}%
    }
    \newrobustcmd\rightwhitearrow{%
      \mathrel{\text{\normalfont\@rdxm@stix\symbol{"21E8}}}%
    }
    \newrobustcmd\downwhitearrow{%
      \mathrel{\text{\normalfont\@rdxm@stix\symbol{"21E9}}}%
    }
}{%
    \let \leftwhitearrow = \Leftarrow
    \let \rightwhitearrow = \Rightarrow
    \let \upwhitearrow = \Uparrow
    \let \downwhitearrow = \Downarrow
}}

