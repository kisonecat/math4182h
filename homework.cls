% homework.cls
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{homework}[2026/01/10 v0.2 Jim Fowler's Homework class]

% ------------------------------------------------------------
% Pass options through to article
% ------------------------------------------------------------
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[12pt]{article}

% ------------------------------------------------------------
% Packages
% ------------------------------------------------------------
\RequirePackage{graphicx}
\RequirePackage{geometry}
\geometry{margin=1.25in,left=1.6in,top=0.5in,bottom=0.8in}

\RequirePackage[compact]{titlesec}
\RequirePackage{amsmath,amsthm,amssymb}
\RequirePackage{fmtcount} % \padzeroes
\RequirePackage{xcolor}
\RequirePackage{sansmath}
\RequirePackage{nopageno}
\RequirePackage{comment} % used to hide solutions if desired

% ------------------------------------------------------------
% Course metadata
% ------------------------------------------------------------
\makeatletter
\newcommand{\@course}{Mathematics}
\newcommand{\course}[1]{\renewcommand{\@course}{#1}}

% Do NOT use \titleline (titlesec uses it internally). Use \hwtitle instead.
\newcommand{\@hwtitle}{\@course}
\newcommand{\hwtitle}[1]{\renewcommand{\@hwtitle}{#1}}
\makeatother

% ------------------------------------------------------------
% Semester / date
% ------------------------------------------------------------
\newcommand{\semestername}{%
  \ifcase\month
    \or Winter% Jan
    \or Winter% Feb
    \or Spring% Mar
    \or Spring% Apr
    \or Spring% May
    \or Summer% Jun
    \or Summer% Jul
    \or Summer% Aug
    \or Autumn% Sep
    \or Autumn% Oct
    \or Autumn% Nov
    \or Autumn% Dec
  \fi
}
\date{\semestername\ \number\year}

% ------------------------------------------------------------
% Problem set number (default: parse first digit-run from jobname)
% ------------------------------------------------------------
\newcounter{problemset}
\setcounter{problemset}{1}

\RequirePackage{expl3}
\ExplSyntaxOn
\regex_extract_once:nnNTF { (\d+) } { \c_sys_jobname_str } \l_tmpa_seq
  {
    \setcounter{problemset}{ \seq_item:Nn \l_tmpa_seq {1} }
  }
  { }
\ExplSyntaxOff

% Manual override (also resets problem counter)
\newcounter{problem}
\newcommand{\problemset}[1]{%
  \setcounter{problemset}{#1}%
  \setcounter{problem}{0}%
}

% Ensure problem numbering starts fresh each document (unless user increments)
\AtBeginDocument{\setcounter{problem}{0}}

% ------------------------------------------------------------
% Title
% ------------------------------------------------------------
\titleformat{\section}{\bfseries}{}{0pt}{}

\makeatletter
\renewcommand{\maketitle}{%
  \begin{center}
    \textbf{\@hwtitle: Problem Set \#\arabic{problemset}}\\
    \@course \quad \semestername\ \number\year
  \end{center}\vspace{-2.5ex}
}
\makeatother

% ------------------------------------------------------------
% Theorem environments (kept from your original)
% ------------------------------------------------------------
\newtheorem{theorem}{Theorem}
\newtheorem{corollary}[theorem]{Corollary}
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}

\theoremstyle{definition}
\newtheorem{remark}[theorem]{Remark}
\newtheorem{example}[theorem]{Example}
\newtheorem{definition}[theorem]{Definition}

% ------------------------------------------------------------
% Common symbols
% ------------------------------------------------------------
\newcommand{\R}{\mathbb{R}}
\newcommand{\Z}{\mathbb{Z}}
\newcommand{\N}{\mathbb{N}}

% ------------------------------------------------------------
% Problem environments + labels (matches your S##P## scheme)
% ------------------------------------------------------------
\setlength{\parindent}{0pt}
\setlength{\parskip}{1ex}

\makeatletter
\newcommand{\@problemlabel}{%
  S\padzeroes[2]{\decimal{problemset}}P\padzeroes[2]{\decimal{problem}}%
}

\newcommand{\@currentproblemlabel}{%
  S\ifnum\value{problemset}<10 0\arabic{problemset}\else\arabic{problemset}\fi
  P\ifnum\value{problem}<10 0\arabic{problem}\else\arabic{problem}\fi
}

\newenvironment{problem}{%
  \refstepcounter{problem}%
  \makebox[0pt][r]{\textbf{\@problemlabel.}\hspace{1em}}%
  \edef\@currentlabel{\@currentproblemlabel}%
  \ignorespaces
}{\vspace{1ex}}

\newenvironment{problem*}{%
  \refstepcounter{problem}%
  \makebox[0pt][r]{\textbf{$\ast$ \@problemlabel.}\hspace{1em}}%
  \edef\@currentlabel{\@currentproblemlabel}%
  \ignorespaces
}{\vspace{1ex}}
\makeatother

% ------------------------------------------------------------
% Inspiration + byline
% ------------------------------------------------------------
\newenvironment{inspiration}{\begin{center}\footnotesize\em}{\end{center}\vspace{-1ex}}
\newcommand{\byline}[1]{\rm---#1}

% ------------------------------------------------------------
% Solution environment (toggleable)
% ------------------------------------------------------------
\newif\ifshowsolutions
\showsolutionstrue % change to \showsolutionsfalse to hide solutions by default

\newenvironment{solution}{%
  \ifshowsolutions
    \vspace{-1.25ex}\color{red!50!gray}\sffamily\sansmath
  \else
    \comment
  \fi
}{%
  \ifshowsolutions
    \color{black}\rmfamily\vspace{1ex}%
  \else
    \endcomment
  \fi
}

% That's all, folks!
\endinput

