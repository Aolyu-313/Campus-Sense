package com.example.campussense.dto;

public class ComfortDto {

    private Integer score;
    private String levelCode;
    private String adviceCode;

    public ComfortDto() {
    }

    public ComfortDto(Integer score, String levelCode, String adviceCode) {
        this.score = score;
        this.levelCode = levelCode;
        this.adviceCode = adviceCode;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
    }

    public String getLevelCode() {
        return levelCode;
    }

    public void setLevelCode(String levelCode) {
        this.levelCode = levelCode;
    }

    public String getAdviceCode() {
        return adviceCode;
    }

    public void setAdviceCode(String adviceCode) {
        this.adviceCode = adviceCode;
    }
}
