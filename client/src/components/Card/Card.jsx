import React from "react";
import { styled } from "@mui/material/styles";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import { CardHeader } from "@mui/material";

const StyledCard = styled((props) => <Card {...props} />)(({ theme }) => ({
  maxWidth: 500,
  margin: "0 auto",
  marginBottom: "1rem",
  marginTop: "1rem",
}));

const CardComponent = (props) => {
  const { title } = props;

  return (
    <StyledCard sx={{ minWidth: 275 }} elevation={5}>
      <CardHeader title={title} />

      <CardContent>{"Hello World"}</CardContent>
    </StyledCard>
  );
};

export default CardComponent;
