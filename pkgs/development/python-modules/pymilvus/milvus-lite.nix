{
  lib,
  pkgs,
  stdenv,
  fetchFromGitHub,
  cmake,
  antlr4,
  grpc,
  pkg-config,
  sqlite,
  sqlitecpp,
}:

stdenv.mkDerivation rec {
  pname = "milvus-lite";
  version = "2.4.11";

  src = fetchFromGitHub {
    owner = "milvus-io";
    repo = "milvus-lite";
    rev = "v${version}";
    hash = "sha256-NdQLrx5wkh42CFjRsRlXu0elht6Hm0Xj23UKg6HZ7u4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    pkgs.protobuf
  ];

  buildInputs = [
    antlr4.runtime.cpp.dev
    grpc
    sqlite
    sqlitecpp
  ];

    cmakeFlags = [
    "-DProtobuf_DIR=${pkgs.protobuf}"
  ];


  meta = {
    description = "A lightweight version of Milvus";
    homepage = "https://github.com/milvus-io/milvus-lite/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "milvus-lite";
    platforms = lib.platforms.all;
  };
}
