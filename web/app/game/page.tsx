"use client";

import { useRef, useEffect, useState } from "react";
import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import CircularProgress from "@mui/material/CircularProgress";

export default function GamePage() {
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const checkGameExists = async () => {
      try {
        const response = await fetch("/game/index.html", { method: "HEAD" });
        if (!response.ok) {
          setError("Game not found. Export the Godot project to web/public/game/");
        }
      } catch {
        setError("Game not found. Export the Godot project to web/public/game/");
      }
    };

    checkGameExists();
  }, []);

  const handleIframeLoad = () => {
    setLoading(false);
  };

  if (error) {
    return (
      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          flex: 1,
          textAlign: "center",
        }}
      >
        <Typography variant="h5" color="error" gutterBottom>
          Game Not Available
        </Typography>
        <Typography color="text.secondary">
          {error}
        </Typography>
      </Box>
    );
  }

  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        flex: 1,
        width: "100%",
      }}
    >
      {loading && (
        <Box
          sx={{
            position: "absolute",
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 2,
          }}
        >
          <CircularProgress />
          <Typography>Loading game...</Typography>
        </Box>
      )}
      <Box
        sx={{
          width: "100%",
          maxWidth: 800,
          aspectRatio: "16/9",
          bgcolor: "background.paper",
          borderRadius: 2,
          overflow: "hidden",
          opacity: loading ? 0 : 1,
          transition: "opacity 0.3s",
        }}
      >
        <iframe
          ref={iframeRef}
          src="/game/index.html"
          onLoad={handleIframeLoad}
          style={{
            width: "100%",
            height: "100%",
            border: "none",
          }}
          allow="autoplay; fullscreen"
        />
      </Box>
    </Box>
  );
}
