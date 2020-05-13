import { constructNewUrlWithParam, stringMatchesPostcode, convertMilesToMetres, convertEpochToUnixTimestamp } from './utils';

describe('constructNewUrlWithParams', () => {
    test('activates autocomplete if threshold has been met', () => {
        expect(constructNewUrlWithParam(
            'location',
            's',
            'https://jobs?radius=20&location=&job_title=#vacancy-results'
        )).toBe(
            'https://jobs?radius=20&location=s&job_title=#vacancy-results'
        );

        expect(constructNewUrlWithParam(
            'location',
            'so',
            'https://jobs?radius=20&location=s&job_title=#vacancy-results'
        )).toBe(
            'https://jobs?radius=20&location=so&job_title=#vacancy-results'
        );
    });
});

describe('stringMatchesPostcode', () => {

    const validPostcodes = [
        'CT9 5ST',
        'ct9 5ST',
        'ct9 5St',
        'CT95ST',
        'SE18 2BT',
        'SE182BT',
        'B2 5ST',
        'B25ST'
    ];

    test('matches a correct postcode', () => {
        validPostcodes.map(postcode => expect(stringMatchesPostcode(postcode)).toBe(true));
    });

    const invalidPostcodes = [
        'CT 5ST',
        'CT5ST',
        'SEF8 2BT',
        'SEF82BT',
        'B2 %ST',
        'B2%ST'
    ];

    test('matches a correct postcode', () => {
        invalidPostcodes.map(postcode => expect(stringMatchesPostcode(postcode)).toBe(false));
    });
});

describe('convertMilesToMetres', () => {
    test('converts an integer of number of miles to the equivalent in metres', () => {
        expect(convertMilesToMetres(1)).toBe(1609.34);
    });

    test('converts a string of number of miles to the equivalent in metres', () => {
        expect(convertMilesToMetres('1')).toBe(1609.34);
    });
});

describe('convertEpochToUnixTimestamp', () => {
    test('converts an epoch timestamp to unix format', () => {
        expect(convertEpochToUnixTimestamp(1589351356458)).toBe(1589351356);
        expect(convertEpochToUnixTimestamp(1589351356658)).toBe(1589351357);
    });
});
