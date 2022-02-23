{ lib, stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "examiner";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "conni2461";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256:03pzrxpiz8xkp9aq08y3a8cxav28mvw4pqsayni9xp45a7igvk5g";
  };

  enableParallelBuilding = true;
  makeFlags = [ "PREFIX=$(out)" "VERSION=$(version)" ];

  meta = with lib; {
    description = "A small, opinionated c unit testing framework";
    homepage = "https://github.com/conni2461/examiner";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ conni2461 ];
  };
}
