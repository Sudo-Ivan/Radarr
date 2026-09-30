import { useLayoutEffect } from 'react';
import { useSelector } from 'react-redux';
import useTheme from 'Helpers/Hooks/useTheme';
import createUISettingsSelector from 'Store/Selectors/createUISettingsSelector';

function ApplyTheme() {
  const theme = useTheme();
  const { enableColorImpairedMode } = useSelector(createUISettingsSelector());

  useLayoutEffect(() => {
    document.documentElement.dataset.theme = theme;

    // Clear variables the old theme injector wrote inline, which would
    // otherwise outrank the stylesheet tokens.
    const root = document.documentElement;

    for (const name of Array.from(root.style)) {
      if (name.startsWith('--')) {
        root.style.removeProperty(name);
      }
    }
  }, [theme]);

  useLayoutEffect(() => {
    if (enableColorImpairedMode) {
      document.documentElement.dataset.colorImpaired = '';
    } else {
      delete document.documentElement.dataset.colorImpaired;
    }
  }, [enableColorImpairedMode]);

  return null;
}

export default ApplyTheme;
