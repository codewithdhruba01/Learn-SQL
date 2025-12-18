#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * Repository Structure Validator
 * Ensures all required directories and files exist
 */

const REQUIRED_CHAPTERS = [
    '00_Installation_and_Setup',
    '01_Introduction',
    '02_SQL_Basics',
    '03_Data_Types_and_Operators',
    '04_DDL_Commands',
    '05_DML_Commands',
    '06_Select_Queries',
    '07_Joins_and_Relationships',
    '08_Group_By_and_Aggregation',
    '09_Subqueries',
    '10_SQL_Functions',
    '11_Constraints_and_Keys',
    '12_Views_and_Indexes',
    '13_Triggers',
    '14_Stored_Procedures',
    '15_Transactions',
    '16_Practice_Projects',
    '17_Window_Functions',
    '18_Common_Table_Expressions',
    '19_Performance_Tuning',
    '20_Advanced_SQL_Techniques',
    '21_Normalization_and_FD'
];

const REQUIRED_FILES = [
    'README.md',
    'CODE_OF_CONDUCT.md',
    'CONTRIBUTING.md',
    '.github/workflows/ci.yml'
];

function validateStructure() {
    console.log('🔍 Validating Repository Structure...\n');

    let errors = [];
    let warnings = [];

    // Check root files
    console.log('📁 Checking root files...');
    REQUIRED_FILES.forEach(file => {
        if (!fs.existsSync(file)) {
            errors.push(`❌ Missing required file: ${file}`);
        } else {
            console.log(`✅ Found: ${file}`);
        }
    });

    // Check chapter directories
    console.log('\n📚 Checking chapter directories...');
    REQUIRED_CHAPTERS.forEach(chapter => {
        const chapterPath = chapter;

        if (!fs.existsSync(chapterPath)) {
            errors.push(`❌ Missing chapter directory: ${chapter}`);
            return;
        }

        console.log(`✅ Found directory: ${chapter}`);

        // Check for README.md in each chapter
        const readmePath = path.join(chapterPath, 'README.md');
        if (!fs.existsSync(readmePath)) {
            errors.push(`❌ Missing README.md in: ${chapter}`);
        } else {
            console.log(`   └─ README.md found`);

            // Basic content validation
            const content = fs.readFileSync(readmePath, 'utf8');
            if (content.length < 1000) {
                warnings.push(`⚠️  README.md in ${chapter} seems too short (${content.length} chars)`);
            }
        }
    });

    // Check for SQL files in appropriate directories
    console.log('\n💾 Checking for SQL example files...');
    const sqlDirs = ['16_Practice_Projects', '21_Normalization_and_FD'];
    sqlDirs.forEach(dir => {
        if (fs.existsSync(dir)) {
            const sqlFiles = fs.readdirSync(dir).filter(file => file.endsWith('.sql'));
            if (sqlFiles.length === 0) {
                warnings.push(`⚠️  No SQL files found in: ${dir}`);
            } else {
                console.log(`✅ Found ${sqlFiles.length} SQL file(s) in: ${dir}`);
            }
        }
    });

    // Check GitHub templates
    console.log('\n🎫 Checking GitHub templates...');
    const templateDirs = [
        '.github/ISSUE_TEMPLATE',
        '.github/PULL_REQUEST_TEMPLATE'
    ];

    templateDirs.forEach(dir => {
        if (!fs.existsSync(dir)) {
            errors.push(`❌ Missing GitHub template directory: ${dir}`);
        } else {
            const files = fs.readdirSync(dir);
            if (files.length === 0) {
                warnings.push(`⚠️  No template files in: ${dir}`);
            } else {
                console.log(`✅ Found ${files.length} template(s) in: ${dir}`);
            }
        }
    });

    // Summary
    console.log('\n📊 Validation Summary:');
    console.log('='.repeat(50));

    if (errors.length === 0) {
        console.log('✅ All critical requirements met!');
    } else {
        console.log(`❌ Found ${errors.length} error(s):`);
        errors.forEach(error => console.log(`   ${error}`));
    }

    if (warnings.length > 0) {
        console.log(`⚠️  Found ${warnings.length} warning(s):`);
        warnings.forEach(warning => console.log(`   ${warning}`));
    }

    // Exit with appropriate code
    if (errors.length > 0) {
        console.log('\n❌ Validation failed!');
        process.exit(1);
    } else {
        console.log('\n✅ Validation passed!');
        if (warnings.length > 0) {
            console.log('Consider addressing the warnings above.');
        }
    }
}

// Run validation
try {
    validateStructure();
} catch (error) {
    console.error('💥 Validation script error:', error.message);
    process.exit(1);
}
