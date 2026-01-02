"use client";

import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import Link from "next/link";

export default function Home() {
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
      <Typography variant="h1" component="h1" gutterBottom>
        Furnace
      </Typography>
      <Typography
        variant="h6"
        color="text.secondary"
        sx={{ mb: 4, maxWidth: 600 }}
      >
        Build walls and runes to defend the last furnace. One fireball. One
        shot.
      </Typography>
      <Stack direction="row" spacing={2}>
        <Button
          component={Link}
          href="/game"
          variant="contained"
          size="large"
          color="primary"
        >
          Play Game
        </Button>
      </Stack>
    </Box>
  );
}
