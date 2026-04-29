package com.example.campussense.validation;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class EnumValueValidator implements ConstraintValidator<EnumValue, String> {

    private Set<String> allowed;

    @Override
    public void initialize(EnumValue annotation) {
        allowed = new HashSet<>(Arrays.asList(annotation.anyOf()));
    }

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null || value.trim().isEmpty()) {
            return true;
        }
        String normalized = value.trim().toUpperCase().replace('-', '_').replace(' ', '_');
        return allowed.contains(value.trim().toUpperCase()) || allowed.contains(normalized);
    }
}
